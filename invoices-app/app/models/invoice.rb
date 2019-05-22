
class Invoice < ActiveRecord::Base

  belongs_to :organization

  def to_s

    if organization then
      org_name = organization.name
    else
      org_name = "unknown"
    end
    if approver.nil? then
      "Invoice #{book_number} for #{org_name} (uploaded: #{uploaded})"
    else
      "Invoice(#{id}): #{book_number} for #{approver} in #{org_name} --> #{file_name} (uploaded : #{uploaded})"
    end
  end

  def Invoice.new_invoices()
    invoices = Invoice.where(uploaded: 0).all
    return invoices
  end


  def success?
    return result == "Success"
  end

  def self.search(org_name)
    if org_name.nil?
      Invoice.all.order(created_at: :desc)
    else
      Organization.find(org_name).invoices
    end
  end
end
