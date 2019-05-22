namespace :invoices do

  desc "Start upload invoices background job"
  task upload_invoices: :environment do
    # launch the upload invoices job in background
    UploadInvoicesJob.perform_later
    Rails.logger.info "Upload invoices job launched"
  end

end
