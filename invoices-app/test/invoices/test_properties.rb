require 'test_helper'

SAMPLE_FILE="sample/invoices.cfg"
MISSING_FILE="this/does/not/exist.cfg"

class TestProperties < ActiveSupport::TestCase

  def test_missing_file_ok()
    InvoiceConfig.load_config(MISSING_FILE)
    assert true
  end

  def test_config_file_and_whitespace_stripping()
    InvoiceConfig.load_config(SAMPLE_FILE)
    value = InvoiceConfig.get('TEST_PROPERTY')
    assert_equal "this is a sample property", value
  end

  def test_flags()
    InvoiceConfig.load_config(SAMPLE_FILE)
    value = InvoiceConfig.get('TEST_FLAG')
    assert value
  end

  def test_environment_override()
    ENV['TEST_PROPERTY'] = 'this is a environment property'
    InvoiceConfig.load_config(SAMPLE_FILE)
    value = InvoiceConfig.get('TEST_PROPERTY')
    assert_equal ENV['TEST_PROPERTY'], value
    ENV.delete('TEST_PROPERTY')
  end
end
