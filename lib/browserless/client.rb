# frozen_string_literal: true

module Browserless
  class ApikeyError < StandardError; end

  class Client
    attr_reader :body_parameters

    def initialize(**kwargs)
      @body_parameters = Browserless.configuration.defaults.merge(kwargs)
    end

    def to_pdf
      temp_file = Tempfile.new
      save_pdf_to_temp_file(temp_file)

      temp_file.read
    ensure
      temp_file.close
      temp_file.unlink
    end

    private

    def save_pdf_to_temp_file(temp_file)
      File.open(temp_file, "wb") do |file|
        file.binmode

        HTTParty.post(Browserless.configuration.url, headers: Browserless::Client.headers, body: body_parameters.to_json, stream_body: true) do |fragment|
          handle_fragment(fragment, file)
        end
      end
    end

    def handle_fragment(fragment, file)
      case fragment.code
      when 401
        error = ApikeyError.new("Unauthorized. Please check if you have a valid Browserless API key")
        raise error
      when 301, 302
        print "skip writing for redirect"
      when 200
        print "."
        file.write(fragment)
      else
        puts fragment
        raise StandardError, "Non-success status code while streaming #{fragment.code}"
      end
    end

    class << self
      def headers
        {
          "Cache-Control": "no-cache",
          "Content-Type": "application/json"
        }
      end
    end
  end
end
