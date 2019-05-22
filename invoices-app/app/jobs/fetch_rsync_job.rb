require 'net/ftp'

class FetchRSyncJob < ActiveJob::Base
  queue_as :default

  def perform(*args)

    # run your code here
    logger.info("Launching FetchRSyncJob with parameters #{args}")

    rsync_scans

    logger.info("FetchRSyncJob has finished.")

  end

  private

  def rsync_scans
    # get locally scanned invoices
    src_dir = InvoiceConfig.get('SRC_DIR').split(',')
    scan_dir = InvoiceConfig.get('SCAN_DIR')

    RsyncInterface.update_database(src_dir, scan_dir)
  end

end
