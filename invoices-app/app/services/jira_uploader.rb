
class JiraUploader

  def initialize(jira)
    @jira = jira
  end

  def upload_invoice(invoice)
    begin
      @jira.create_issue(invoice)

      invoice.result = 'Success'
      invoice.uploaded = 1
    rescue
      invoice.result = $!
    ensure
      invoice.save
    end
  end

end
