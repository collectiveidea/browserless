require "test_helper"

class Browserless::ConfigurationTest < Minitest::Test
  def setup
    @configuration = Browserless::Configuration.new
  end

  def test_api_key_accessor
    api_key = "test_key"

    @configuration.api_key = api_key

    assert_equal api_key, @configuration.api_key
  end

  def test_missing_api_key_raises_error
    assert_raises(Browserless::ConfigurationError) do
      @configuration.api_key
    end
  end

  def test_options_accessor
    example_options = {options: {displayHeaderFooter: true, landscape: false}}

    @configuration.options = example_options

    assert_equal example_options[:options], @configuration.options[:options]
  end

  def test_host
    assert_equal "https://production-sfo.browserless.io", @configuration.host
  end
end
