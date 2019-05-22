require 'net/ftp'

class FetchFtpJob < ActiveJob::Base
  queue_as :default

  def perform(*args)

    logger.info("Getting scans with ftp")

    ftp_scans

    logger.info("FetchFtpJob has finished.")

  end


  def ftp_scans
    # get ONEA invoices
    ftp_server=InvoiceConfig.get('FTP_SERVER')
    onea_username=InvoiceConfig.get('ONEA_USERNAME')
    onea_password=InvoiceConfig.get('ONEA_PASSWORD')

    ftp = Net::FTP.open(ftp_server)
    ftp.passive = true
    ftp.login(onea_username, onea_password)
    FtpInterface.update_database(ftp)
  end


end
