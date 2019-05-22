
def get_basename(path)
  return File::basename(path.downcase,".pdf")
end

def create_invoice(path)
  bn = Date::today.strftime("%Y%m%d") + "_" + get_basename(path)
  pieces = path.split '/'
  org = pieces[-2]
  unless Invoice.where(organization: org, book_number: bn).first
    return Invoice.new(:organization => org,
                       :book_number => bn.to_s,       # convert to a string
                       :file_name => path, :uploaded => false)
  end
end
