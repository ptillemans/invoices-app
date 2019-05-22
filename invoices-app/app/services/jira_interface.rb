require 'jira4r/jira_tool'
require 'base64'

PROJECT = InvoiceConfig.get('PROJECT')
INVOICE_TYPE = InvoiceConfig.get('INVOICE_TYPE')

WEBSITE = InvoiceConfig.get('WEBSITE')
USERNAME= InvoiceConfig.get('USERNAME')
PASSWORD = InvoiceConfig.get('PASSWORD')

SUPPLIER_FIELD_ID = InvoiceConfig.get('SUPPLIER_FIELD_ID')
AMOUNT_FIELD_ID = InvoiceConfig.get('AMOUNT_FIELD_ID')
REFERENCE_FIELD_ID = InvoiceConfig.get('REFERENCE_FIELD_ID')


# Monkeypatch the WSDL
require 'jira4r/v2/JiraSoapServiceDriver'
Jira4R::V2::JiraSoapService::Methods += [[ XSD::QName.new(Jira4R::V2::JiraSoapService::NsSoapRpcJiraAtlassianCom, "addBase64EncodedAttachmentsToIssue"),
          "",
          "addBase64EncodedAttachmentsToIssue",
          [ ["in", "in0", ["::SOAP::SOAPString"]],
            ["in", "in1", ["::SOAP::SOAPString"]],
            ["in", "in2", ["Jira4R::V2::ArrayOf_xsd_string", "http://jira.atlassian.com/rpc/soap/jirasoapservice-v2", "ArrayOf_xsd_string"]],
            ["in", "in3", ["Jira4R::V2::ArrayOf_xsd_string", "http://jira.atlassian.com/rpc/soap/jirasoapservice-v2", "ArrayOf_xsd_string"]],
            ["retval", "addAttachmentsToIssueReturn", ["::SOAP::SOAPBoolean"]] ],
          { :request_style =>  :rpc, :request_use =>  :encoded,
            :response_style => :rpc, :response_use => :encoded,
            :faults => {"Jira4R::V2::RemoteAuthenticationException_"=>{:use=>"encoded", :name=>"RemoteAuthenticationException", :ns=>"http://jira.atlassian.com/rpc/soap/jirasoapservice-v2", :namespace=>"http://jira.atlassian.com/rpc/soap/jirasoapservice-v2", :encodingstyle=>"http://schemas.xmlsoap.org/soap/encoding/"}, "Jira4R::V2::RemotePermissionException_"=>{:use=>"encoded", :name=>"RemotePermissionException", :ns=>"http://jira.atlassian.com/rpc/soap/jirasoapservice-v2", :namespace=>"http://jira.atlassian.com/rpc/soap/jirasoapservice-v2", :encodingstyle=>"http://schemas.xmlsoap.org/soap/encoding/"}, "Jira4R::V2::RemoteValidationException_"=>{:use=>"encoded", :name=>"RemoteValidationException", :ns=>"http://jira.atlassian.com/rpc/soap/jirasoapservice-v2", :namespace=>"http://jira.atlassian.com/rpc/soap/jirasoapservice-v2", :encodingstyle=>"http://schemas.xmlsoap.org/soap/encoding/"}, "Jira4R::V2::RemoteException_"=>{:use=>"encoded", :name=>"RemoteException", :ns=>"http://jira.atlassian.com/rpc/soap/jirasoapservice-v2", :namespace=>"http://jira.atlassian.com/rpc/soap/jirasoapservice-v2", :encodingstyle=>"http://schemas.xmlsoap.org/soap/encoding/"}} }
                                        ]]


class JiraInterface

  attr_accessor :jira

  # Create a JIRA Interface instance using the URL and login parameters
  def JiraInterface.instance(jiraurl, username, password)
    jiratool = Jira4R::JiraTool.new(2, jiraurl)
    jiratool.login(username, password)
    new(jiratool)
  end

  # Create an instance based on a Jira4R.jira_tool like object
  def initialize(jiratool)
    @jira = jiratool
  end

  # get the list of components available
  def components
    unless @components
      comps = @jira.getComponents(PROJECT)
      @components = Hash.new(0)
      comps.each { |comp|
          @components[comp.name] = comp
      }
    end
    return @components
  end

  def _get_issuetype(itype)
        types = @jira.getIssueTypes()
        it = types.find { |x|  x.name == itype }
        if it == nil then
            raise "Unknown issuetype specified : #{itype}"
        end
        return it.id
  end

  # get the configured issuetype
  def issuetype
    unless @issuetype
        @issuetype = _get_issuetype(INVOICE_TYPE)
    end
    return @issuetype;
  end

  # Pretty-print an issue
  def print_issue(issue)
    puts "Issue #{issue.id}"
    puts "  project     : #{issue.project}"
    puts "  type        : #{issue.type}"
    puts "  summary     : #{issue.summary}"
    puts "  description : #{issue.description}"
    puts "  components  : #{issue.components[0].name}"
    puts "  reporter    : #{issue.reporter}"
    puts "  assignee    : #{issue.assignee}"
    puts "  status      : #{issue.status}"
  end

  # Create the issue in Jira.
  #
  # If the creation failed, it is highly likely that the cause was that the assignee is not assignable
  # or does not exist. This is manually typed information in the input files impossible to validate
  # without going to Jira. In this case we first try to create the issue assigned to the default admin
  #
  def _create_jira_issue(issue, organization)
    begin
      begin

        puts ("Creating issue : #{issue.summary}")
        puts ("   approver = #{issue.assignee}")

        # try creating the ticket
        return @jira.createIssue(issue)
      rescue Exception => ex
        puts "exception received when creating issue : " + ex.to_s
        # if it fails try assigning it to the admin user
        issue.assignee = organization.default_approver
        issue.description = "Upload of invoice assigned to #{issue.assignee} failed with message : #{ex.message}"
        return @jira.createIssue(issue)
      end
    rescue Exception => ex2
      puts "Exception creating issue : #{ex2}"
      puts "#{ex2.backtrace}"
      raise Exception.new, "Exception creating issue"
    end
    return nil
  end

  # Return the component corresponding to the organization as an array.
  #
  # If the component is not found then an empty array is returned.
  def _find_org_components (org)
    comps = []
    if self.components.has_key?(org)
        comps << self.components[org]
    end
    return comps
  end

  # Upload the file with given filename as an attachment to the issue
  def _upload_file(issue, filename)
    begin
      filedata = File.open(filename, "rb") { |f| f.read }
      attachmentData = Base64.encode64(filedata)
      fname = File.basename(filename)
      @jira.addBase64EncodedAttachmentsToIssue(issue.key, [fname], [attachmentData])
    rescue Exception => ex2
      Rails.logger.error "Exception uploading file : #{ex2}"
      Rails.logger.error "#{ex2.backtrace}"
    end
  end

  def default_approver(organization)
    if Organization.exists?(name: organization)
      return Organization.where(name: organization).first.default_approver || @admin
    else
      return @admin
    end
  end

  # Create Jira ticket based on information passed in the Invoice object.
  #
  # Note: the file pointed to by the filename field in the invoice will be uploaded as
  # an attachment.
  def create_issue(invoice)
    onea_invoice = invoice.approver.nil?

    issue = Jira4R::V2::RemoteIssue.new()

    issue.project = PROJECT
    issue.reporter = USERNAME

    if onea_invoice then
      issue.assignee = default_approver(invoice.organization.name)
      issue.summary = "Invoice #{invoice.book_number} for #{invoice.organization.name}"
      issue.description = "Invoice #{invoice.book_number} for #{invoice.organization.name}"

      #Add customfield value
      custom_field = Jira4R::V2::RemoteCustomFieldValue.new
      custom_field.customfieldId = REFERENCE_FIELD_ID
      custom_field.values = invoice.book_number
      issue.customFieldValues = [custom_field]
    else
      issue.assignee = invoice.approver
      issue.summary = "Invoice with booking #{invoice.book_number} for #{invoice.organization.name}"
      issue.description = "Invoice with booking #{invoice.book_number} for #{invoice.organization.name}"
    end

    issue.type = issuetype
    issue.components = _find_org_components(invoice.organization.name)


    puts "Created issue #{issue.summary}"

    if get_all_invoices_from_jira('"' + issue.summary + '"').size == 0 then

      puts("uploading files for #{issue.summary} : #{invoice.file_name}")
      new_issue = _create_jira_issue(issue,invoice.organization)
      _upload_file(new_issue, invoice.file_name)

      if invoice.approver == 'xxx'
        close_issue(new_issue)
      else
        unless onea_invoice then
          open_issue(new_issue)
        end
      end
    else
       puts "#{issue.summary} already exists. Skipping"
    end
  end

  # Create the user in Jira is he/she does not exist already
  #
  def update_user(user)
    jira_user = @jira.getUser(user.uid.downcase)
    if jira_user
      # puts "User #{user.uid} already exists"
    else
      begin
        jira_user = @jira.createUser(user.uid, user.password, user.fullname, user.email)
        # puts("User #{user.uid} was updated : #{jira_user.name}")
      rescue Exception => bang
        puts "Error caught : #{bang}"
        puts "#{bang.backtrace}"
        puts "Probably the user #{user.uid} was not created."
      end
    end
  end

  # Get the information from the Jira issue to create a corresponding
  # invoice record.
  #
  def create_invoice_from_issue(issue)
      desc = issue.summary
      booking = desc.scan(/booking (.*) for/)[0][0]
      org = desc.scan(/ for (.*)/)[0][0]

      inv = Invoice.new()
      inv.organization = Organization.find_or_create_by(name: org)
      inv.book_number = booking
      inv.approver = issue.assignee
      inv.file_name = "dummy"
      inv.uploaded = true
      inv.jira_id = issue.key
      inv.jira_status = issue.status
      return inv
  end

  # Get all invoices in Jira and create corresponding invoices in the local db.
  #
  def get_all_invoices_from_jira(pattern)
      issues = @jira.getIssuesFromTextSearchWithProject(["INVAPP"],pattern,9999)
      return issues
  end

  def copy_all_invoices_from_jira(pattern)
      get_all_invoices_from_jira(pattern).each { |issue|
      begin
        inv = create_invoice_from_issue(issue)
        inv.save()
      rescue Exception => bang
        puts "Error caught : #{bang}"
        puts "#{bang.backtrace}"
        puts "Probably the summary field was unparsable"
      end
    }
  end

  # Return status id corresponding to the name given
  #
  # lazy loads a lookup table as a cache.
  def get_status_id(status)
    if ! @statii
      @statii = {}
      @jira.getStatuses().each { |s|
        @statii[s.name] = s.id
      }
    end
    return @statii[status]
  end

  # Perform the workflow action with the given name and fill in the
  # attribs in the issue
  def workflow_action(issue,name, attribs)
    actions = @jira.getAvailableActions(issue.key).each() { |action|
        if action.name == name
          @jira.progressWorkflowAction(issue.key, action.id, attribs)
        end
    }
  end

  # Update the attributes on the given issue.
  #
  # Attributes passed as  an array of RemoteFieldValues
  def update_issue(issue, attribs)
    @jira.updateIssue(issue.key, attribs)
  end

  # Close the issue
  def close_issue(issue)
    if issue.status != get_status_id("Closed")
      newassignee = Jira4R::V2::RemoteFieldValue.new("assignee", ["uploader"])
      oldassignee = Jira4R::V2::RemoteFieldValue.new("assignee", issue.assignee)
      newissuetype = Jira4R::V2::RemoteFieldValue.new("issuetype", [issuetype])
      resofixed = Jira4R::V2::RemoteFieldValue.new("resolution", "1")

      update_issue(issue, [newassignee])
      workflow_action(issue,"Approve", [newassignee, newissuetype, resofixed])
      workflow_action(issue,"Complete", [oldassignee, newissuetype, resofixed])
    end
  end

  # Assign the issue --> move it from New to Open state
  def open_issue(issue)
    if issue.status == get_status_id("New") then
      workflow_action(issue, "Assign Invoice", [])
    end
  end

  # Reopen the issue
  def reopen_issue(issue)
    if issue.status == get_status_id("Closed")
        oldassignee = Jira4R::V2::RemoteFieldValue.new("assignee", ["kre"])
        update_issue(issue, [oldassignee])
        workflow_action(issue,"Reopen",[oldassignee])
    end
  end

  def add_pending_booking_info()
    Booking.where(uploaded: false).all.each {|booking|
      begin
        sup = Jira4R::V2::RemoteFieldValue.new(SUPPLIER_FIELD_ID, [booking.supplier])
        amt = Jira4R::V2::RemoteFieldValue.new(AMOUNT_FIELD_ID, [booking.amount.to_s])
        add_booking_info(booking, [sup, amt]);
      rescue Exception => e
        puts "Exception occured : #{e}"
      end
    }
  end

  def add_booking_info(booking, attributes)
    pattern = "\"#{booking.book_number} for #{booking.organization}\""
    puts "Adding booking info for #{pattern}"
    get_all_invoices_from_jira(pattern).each do |issue|
      update_issue(issue, attributes)
    end
    booking.uploaded = true
    booking.save
  end

  def upload_issue(invoice)
    Rails.logger.info("Jira: Uploading #{invoice}")
    create_issue(invoice)
  end


end
