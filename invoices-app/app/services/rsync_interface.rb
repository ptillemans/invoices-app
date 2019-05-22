require 'find'

class RsyncInterface

  def self.update_database(sources, target)
    new_files = false
    sources.gsub('"','').split.each do |source|
      Rails.logger.info("running rsync -a #{source} #{target}")
      Rsync.run("-a", source, target) do |result|
        if result.success?
          unless result.changes.empty?
            new_files = true
          end
        else
          Rails.logger.error "rsync error : #{result.error} (rsync -a #{source} #{target})"
        end
      end
    end
    GC.start()
    RsyncInterface.add_new_scans(target)
  end

  def self.add_new_scans(dir)
    Rails.logger.info("looking for new invoices in #{dir}")
	  Find.find("#{dir}") { |path|
		  begin
        Rails.logger.info "checking #{path}"
        next unless path
        next if File::directory?("#{path}")

        pieces = path.split '/'
        bn = File::basename(pieces[-1].downcase(),".pdf")
        (nr, approver) = bn.split(/[_.-]/)
        org = Organization.find_or_create_by(name:pieces[-2])
        approver = org.default_approver unless approver
        Rails.logger.info("Invoice scan #{nr} for #{org}")
        unless Invoice.where(organization: org, book_number: nr).first
          inv = Invoice.new(:organization => org,
                            :book_number => nr.to_s(),       # convert to a string
                            :approver => approver,
                            :file_name => path,
                            :uploaded => false
                           )
          inv.save()
        end
        GC.start()
      rescue Exception => bang
        Rails.logger.error "ERROR : Exception occured : #{bang}"
        Rails.logger.error "#{bang.backtrace}"
      end
	  }
  end

  private

  # Create an invoice for the corresponding path if path is new.
  # Returns nil if invoice with this path already exists.
  # * Params:
  #     +path+:: the path to the scanned invoice
  # * Returns::
  #     an Invoice object or *nil* if this scan was already added.
  def self.create_invoice(path)
    pieces = path.split '/'
    if pieces[-1]
      bn = File::basename(pieces[-1].downcase(),".pdf")
      (nr, approver) = bn.split(/[_.-]/)
      org = pieces[-2]
      approver = org.default_approver unless approver
      unless Invoice.where(organization: org, book_number: bn).first
        return Invoice.new(:organization => org,
                           :book_number => nr.to_s(),       # convert to a string
                           :approver => approver,
                           :file_name => path,
                           :uploaded => false
                          )
      end
    end
  end

end
