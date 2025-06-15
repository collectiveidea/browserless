# frozen_string_literal: true

module Browserless
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

        conn = Faraday.new(Browserless.configuration.host) do |builder|
          builder.request :json
          builder.response :raise_error
          builder.response :logger, Browserless.configuration.logger,
            {headers: true, bodies: Browserless.configuration.debug, errors: true}
        end

        data = body_parameters.merge(api_key: Browserless.configuration.api_key)

        conn.post("/pdf", data) do |f|
          f.options.on_data = proc do |fragment, overall_received_bytes|
            print "." if Browserless.configuration.debug
            file.write(fragment)
          end
        end
      end
    end
  end
end
