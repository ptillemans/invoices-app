require 'fileutils'

EXCLUDED_DIRS=InvoiceConfig.get('EXCLUDED_DIRS')
ARCHIVE_DIR=InvoiceConfig.get('ARCHIVE_DIR')

class FtpInterface
  def self.update_database(ftp)
    list_all_files(ftp).each do |file|
      directory = File.dirname(file)

      FileUtils.mkdir_p("/tmp/#{directory}")

      path = "/tmp/#{directory}/#{File.basename(file)}"
      inv = FtpInterface.create_invoice(path)
      unless inv.nil?
        #only download invoice when not existing in database
        ftp.getbinaryfile(file, path)
        inv.save()
        move_invoice_to_archive(ftp, file, directory)
      end
      GC.start()
    end
  end

  private

  # Create an invoice for the corresponding path if path is new.
  # Returns nil if invoice with this path already exists.
  # * Params:
  #     +path+:: the path to the scanned invoice
  # * Returns::
  #     an Invoice object or *nil* if this scan was already added.
  def self.create_invoice(path)
    bn = Date::today.strftime("%Y%m%d") + "_"
    bn += File::basename(path.downcase,".pdf")

    pieces = path.split '/'
    org_name = pieces[-2]
    org = Organization.find_or_create_by(name: org_name)
    puts("Org: #{org} for #{org_name}")
    invoice = Invoice.where(organization: org, book_number: bn).first
    if invoice
      return nil
    else
      return Invoice.create(:organization => org,
                         :book_number => bn.to_s,       # convert to a string
                         :file_name => path, :uploaded => false)
    end
  end


  def self.move_invoice_to_archive(ftp, file, directory)
    begin
      ftp.rename(file, "#{ARCHIVE_DIR}/#{directory}/#{Date::today.strftime("%Y%m%d")}_#{File.basename(file)}")
    rescue Exception => e
      Rails.logger.info "Exception when moving file to archive : #{e.message}"
      Rails.logger.info "Creating folder #{ARCHIVE_DIR}/#{directory}"
      ftp.mkdir("#{ARCHIVE_DIR}/#{directory}")
      ftp.rename(file, "#{ARCHIVE_DIR}/#{directory}/#{Date::today.strftime("%Y%m%d")}_#{File.basename(file)}")
    end
  end

  def self.list_all_files(ftp, dir='.')
    files = []

    ftp.list(dir).each do |item|
      if !directory_excluded?(item)
        if is_directory?(item)
          files += list_all_files(ftp, "#{dir}/#{file_name(item)}")
        else
          files << "#{dir}/#{file_name(item)}"
        end
      end
    end

    return files
  end

  def self.directory_excluded?(item)
    excluded = false
    if is_directory?(item) then
      directory = file_name(item)
      EXCLUDED_DIRS.split(',').each do |dir|
        if dir.eql?(directory) then
          excluded = true
        end
      end
    end

    return excluded
  end

  def self.is_directory?(item)
    item.split(" ").first =~ /^d/
  end

  def self.file_name(item)
    filename_end = item.length - 56
    item[56, filename_end]
  end
end
