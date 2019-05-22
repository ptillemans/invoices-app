
class InvoiceConfig
  @@config = {
    "DATABASE_FILE" => "/var/lib/invoices/invoices.db",
    "WEBSITE" => "https://jira-test.melexis.com/jira/rpc/soap/jirasoapservice-v2?wsdl",
    "USERNAME" => "uploader",
    "PASSWORD" => "password",
    "PROJECT" => "INVAPP",
    "INVOICE_TYPE" => "Invoice",
    "SCAN_DIR" => "/var/lib/invoices",
    "SRC_DIR" => "/tmp/incoming/",
    "SUPPLIER_FIELD_ID" => "customfield_10070",
    "AMOUNT_FIELD_ID" => "customfield_10071",
    "REFERENCE_FIELD_ID" => "customfield_10072",
    "FTP_SERVER" => "openft-test.elex.be",
    "ONEA_USERNAME" => "onea",
    "ONEA_PASSWORD" => "password",
    "EXCLUDED_DIRS" => "archive,logs,new",
    "ARCHIVE_DIR" => "archive",
    "VIIPER_USERNAME" => "apps",
    "VIIPER_PASSWORD" => "apps",
    "VIIPER_DB_URL" => "//viiperdb-test.apps.elex.be/VIPRTEST",
    "VIIPER_APEX_ID" => 106,
    "VIIPER_RSYNC_PREFIX" => "oracle@viiperdb-test.apps.elex.be:"
  }

  def InvoiceConfig.load_properties(properties_filename)
    properties = {}
    File.open(properties_filename, 'r') do |properties_file|
      properties_file.read.each_line do |line|
        line.strip!
        if (line[0] != ?# and line[0] != ?=)
          parts = line.split('=').map(&:strip)
          properties[parts[0]] = parts[1] || ''
        end
      end
    end
    properties
  end

  def InvoiceConfig.get(key, default='')
    rslt = default
    if (@@config[key])
      # Environment variables trump config files
      rslt = ENV[key] || @@config[key]
    end
    return rslt
  end

  def InvoiceConfig.set(key, value)
    @@config[key]=value
  end

  def InvoiceConfig.load_config(filename)
    if File.exist?(filename)
    then
      @@config.merge!(load_properties(filename))
    end
  end

  def InvoiceConfig.load_system_config()
    load_config("/etc/invoices.cfg")
    load_config('~/.invoices.cfg')
  end
end

InvoiceConfig.load_system_config()
