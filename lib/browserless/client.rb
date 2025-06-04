# frozen_string_literal: true

require_relative "options"
require_relative "style_tag"

module Browserless
  class ApikeyError < StandardError; end

  class Client
    attr_reader :html, :url, :style_tag, :emulate_media_type, :goto_options, :options

    def initialize(html:, options: {}, **kwargs)
      @html = html
      @options = Options.new(**options).to_h
      @style_tag = StyleTag.new(kwargs[:style_tag]).to_h
      @emulate_media_type = config_value(:emulate_media_type, kwargs[:emulate_media_type]) || "screen"
      @goto_options = kwargs[:goto_options] || {waitUntil: "networkidle2"}
      @url = Browserless.configuration.url
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

        HTTParty.post(Browserless.configuration.url, headers: Browserless::Client.headers, body: browserless_options.to_json, stream_body: true) do |fragment|
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

    def browserless_options
      {
        html: html,
        emulateMediaType: emulate_media_type,
        addStyleTag: [style_tag],
        gotoOptions: @goto_options,
        options: options
      }
    end

    def config_value(key, value)
      value || Browserless.configuration.send(key)
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
