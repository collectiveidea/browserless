# frozen_string_literal: true

module Browserless
  class Client
    attr_reader :body_parameters

    def initialize(**kwargs)
      @body_parameters = Browserless.configuration.options.merge(kwargs)
    end

    # Returns a string containing the PDF data
    def to_pdf
      Tempfile.create do |tempfile|
        to_pdf_file(tempfile)
        return tempfile.read
      end
    end

    # Returns a File object of the PDF
    def to_pdf_file(filename)
      File.open(filename, "wb") do |file|
        file.binmode

        conn = Faraday.new(Browserless.configuration.host) do |builder|
          builder.request :json
          builder.response :raise_error
          builder.response :logger, Browserless.configuration.logger,
            {headers: true, bodies: Browserless.configuration.debug, errors: true}
        end

        conn.post("/pdf?token=#{Browserless.configuration.api_key}", body_parameters) do |f|
          f.options.on_data = proc do |fragment, _overall_received_bytes|
            print "." if Browserless.configuration.debug
            file.write(fragment)
          end
        end
      end
    end
  end
end
