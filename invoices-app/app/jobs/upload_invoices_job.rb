require 'net/ftp'

class UploadInvoicesJob < ActiveJob::Base
  queue_as :default

  def perform(*args)

    # run your code here
    logger.info("Launching UploadInvoicesJob with parameters #{args}")

    logger.info("Creating new uploader")
    @uploader = Uploader.new(jira: jira_interface())

    logger.info "Uploading invoices"
    @uploader.upload_invoices()

    logger.info("UploadInvoicesJob has finished.")

  end

  private

  def jira_interface
    logger.info "Creating jira_interface"
    website = InvoiceConfig.get('JIRA_URL')
    username = InvoiceConfig.get('JIRA_USERNAME')
    password = InvoiceConfig.get('JIRA_PASSWORD')
    puts "Connecting to #{website} using #{username}/#{password}"
    jira = JiraInterface.instance(website, username, password)
    return JiraUploader.new(jira)
  end

end
