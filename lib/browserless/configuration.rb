# frozen_string_literal: true

module Browserless
  class ConfigurationError < StandardError; end

  class Configuration
    attr_writer :api_key
    attr_accessor :host, :logger, :debug

    def initialize
      @api_key = nil
      @host = "https://production-sfo.browserless.io"
      @logger = Logger.new($stdout)
      @debug = false
      @body_parameters = {
        gotoOptions: {waitUntil: "networkidle2"},
        options: {
          displayHeaderFooter: false,
          format: "A4",
          landscape: false,
          printBackground: false
        }
      }
    end

    def api_key
      return @api_key if @api_key

      error = "Api key missing. Check if you have defined an api key in the config/browserless.rb file."
      raise ConfigurationError, error
    end

    # Shortcuts for accessing options key in the body parameters
    def options
      @body_parameters
    end

    def options=(options)
      @body_parameters.merge!(options)
    end
  end
end
