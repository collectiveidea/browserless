# frozen_string_literal: true

module Browserless
  class ConfigurationError < StandardError; end

  class Configuration
    attr_writer :api_key
    attr_accessor :host, :logger, :debug, :defaults

    def initialize
      @api_key = nil
      @host = "https://production-sfo.browserless.io"
      @logger = Logger.new($stdout)
      @debug = false
      @defaults = {
        emulateMediaType: "screen",
        gotoOptions: {waitUntil: "networkidle2"},
        options: {
          displayHeaderFooter: false,
          format: "A4",
          landscape: false,
          print_background: false
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
      defaults[:options]
    end

    def options=(value)
      defaults[:options] = value
    end
  end
end
