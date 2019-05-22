
class Uploader

  def initialize(args = {})
    @loaders = args
  end

  def upload_invoices()
    Rails.logger.info "Uploader : Upload invoices."
    Invoice.new_invoices().each do |invoice|
      begin

        org = Organization.by_name(invoice.organization.name)
        if org
          puts "Organization #{org.name} has backends #{org.backends}"
          org.backends.each do |backend|
            puts "Uploading invoice for #{org.name} to #{backend}"
            loader = @loaders[backend.to_sym]
            if loader
              Rails.logger.info("uploading #{invoice} using #{loader}")
              loader.upload_invoice(invoice)
            else
              invoice.result = "No loader defined for organization #{invoice.organization}"
            end
          end
        else
          Rails.logger.error "No organization found for #{invoice}"
          invoice.result = "No organization configuration found."
        end
      rescue
        Rails.logger.error "Error uploading invoice #{invoice} : #{$!}"
        invoice.result = $!
      end
      invoice.save
      GC.start()
    end
  end
end
