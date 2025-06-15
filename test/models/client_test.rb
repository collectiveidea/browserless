require "test_helper"

class Browserless::ClientTest < Minitest::Test
  def setup
    Browserless.configure do |config|
      config.api_key = "test_key"
    end
  end

  def teardown
    Browserless.configure { nil }
  end

  def test_headers
    expected_headers = {
      "Cache-Control": "no-cache",
      "Content-Type": "application/json"
    }
    assert_equal expected_headers, Browserless::Client.headers
  end

  def test_initialize
    client = Browserless::Client.new(html: "<html></html>")

    assert_equal "<html></html>", client.body_parameters[:html]
    assert_equal "screen", client.body_parameters[:emulateMediaType]
    assert_nil(client.body_parameters[:addStyleTag])
  end

  def test_existing_browserless_api_key
    client = Browserless::Client.new(html: "<html></html>")

    assert_raises("Unauthorized. Please check if you have a valid Browserless API key") do
      client.to_pdf
    end
  end

  def test_initialize_with_add_style_tag
    client = Browserless::Client.new(html: "<html></html>", addStyleTag: ["<style>body { font-family: Arial; }</style>"])

    assert_equal(["<style>body { font-family: Arial; }</style>"], client.body_parameters[:addStyleTag])
  end

  def test_initialize_with_custom_options
    Browserless.configure do |config|
      config.api_key = "test_key"
      config.options = {}
    end

    client = Browserless::Client.new(
      html: "<html></html>",
      emulateMediaType: "print",
      options: {displayHeaderFooter: true}
    )

    assert_equal "<html></html>", client.body_parameters[:html]
    assert_equal "print", client.body_parameters[:emulateMediaType]
    assert_equal({
      displayHeaderFooter: true
    }, client.body_parameters[:options])
  end
end
