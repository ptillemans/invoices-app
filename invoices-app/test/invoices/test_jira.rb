require 'test_helper'
require 'jira4r/jira_tool'

require "jira4r/v2/jiraService.rb"
require "jira4r/v2/JiraSoapServiceDriver.rb"
require "jira4r/v2/jiraServiceMappingRegistry.rb"

Components = ['Xtrion', "Elex", "Fremach"]
Mlx_admin = 'tbb'
Xtrion_admin = 'kae'
Valid_users = ['abc', Mlx_admin, 'znu', 'lit', 'kcc', 'kre', "tbb", 'xyz', 'kae']
Reference_field_id = 'customfield_10072'

class BookingStub
  attr_accessor :book_number
  attr_accessor :organization
  attr_accessor :uploaded

  def save

  end
end

class InvoiceStub
  attr_accessor :id
  attr_accessor :file_name
  attr_accessor :approver
  attr_accessor :organization
  attr_accessor :book_number
end

class ComponentStub

  attr_accessor :id
  attr_accessor :name

end

class IssueTypeStub

  attr_accessor :id
  attr_accessor :name

end

class StatusStub

  attr_accessor :id
  attr_accessor :name

  def initialize(id,name)
    self.id = id
    self.name = name
  end

end

class ActionStub

  attr_accessor :id
  attr_accessor :name

  def initialize(id,name)
    self.id = id
    self.name = name
  end

end

class IssueStub

  attr_accessor :key
  attr_accessor :summary
  attr_accessor :assignee
  attr_accessor :id
  attr_accessor :status

  def initialize(key, summary, assignee)
    self.key = key
    self.summary = summary
    self.assignee = assignee
    self.id = 0
    self.status = 1
  end
end

class JiraStub

  attr_accessor :issue
  attr_accessor :filenames
  attr_accessor :filecontents
  attr_accessor :attributes
  attr_accessor :actions

  def createIssue(issue)
    if Valid_users.include?(issue.assignee)
    then
      @issue = issue
    else
      raise RuntimeError.new("#{issue.assignee} is not a valid assignee.")
    end
    @attributes = []
    @actions=[]
    @issue.status = 5
    return @issue
  end

  def addAttachmentsToIssue(key, filenames, filecontents)
    self.filenames = filenames
    self.filecontents = filecontents.map { |f| Base64.decode64(f) }
  end

  def addBase64EncodedAttachmentsToIssue(key, filenames, filecontents)
    addAttachmentsToIssue(key, filenames, filecontents)
  end

  def getComponents(project)
    comps = []
    i = 0
    Components.each { |org|
      c = ComponentStub.new()
      c.name = org
      c.id = i
      i = i + 1
      comps << c
    }
    return comps
  end

  def getIssueTypes()
    its = []
    i = 0
    ["Bug", "Invoice", "Feature"].each { |it|
      c = IssueTypeStub.new()
      c.name = it
      c.id = i
      i = i + 1
      its << c
    }
    return its
  end

  def getIssuesFromTextSearchWithProject(projects,filter,max_nr_results)
     issue_map = {
       "Invoice with booking pre1 123456 for My Org" => "abc",
       "Invoice with booking pre2 123456 for Another Org"=> "def",
       "Invoice with booking 666666 for Organization" => "abc",
       "Invoice with booking 765432 for Another Org" => "abc"
     }
     pattern=filter[1..-2]
     i = 0
     issues = []
     issue_map.keys.grep(/#{pattern}/) { |key|
       issues << IssueStub.new(i, key, issue_map[key])
     }

     return issues
  end

  def updateIssue(key, attribs)
    @attributes << attribs
  end

  def getAvailableActions(key)
     actions = []

     # the first number indicates the status after the action
     actions << ActionStub.new(2,"Approve")
     actions << ActionStub.new(3,"Complete")
     actions << ActionStub.new(1,"Reopen")
     actions << ActionStub.new(1,"Assign Invoice")
     return actions
  end

  def progressWorkflowAction(key, id, attribs)
    updateIssue(key,attribs)
    @actions << id
    statuses = getStatuses()
    new_status = statuses[id]
    @issue.status = id
    return @issue
  end

  def getStatuses()
     statuses = []
     statuses << StatusStub.new(1,"Open")
     statuses << StatusStub.new(2,"Approved")
     statuses << StatusStub.new(3,"Closed")
     statuses << StatusStub.new(4,"Denied")
     statuses << StatusStub.new(5,"New")
  end
end

class JiraTest < ActiveSupport::TestCase


  def setup
    @mockjira = JiraStub.new()
    @jira = JiraInterface.new(@mockjira)

    @xtrion = Organization.find_or_create_by(name: 'Xtrion', default_approver: Xtrion_admin)
    @melexis = Organization.find_or_create_by(name: 'Melexis', default_approver: Mlx_admin)
    @melexis_ieper = Organization.find_or_create_by(name: 'Melexis Ieper',default_approver: Mlx_admin)
    @my_org = Organization.find_or_create_by(name: 'My Org', default_approver: Mlx_admin)
    @another_org = Organization.find_or_create_by(name: 'Another Org', default_approver: Mlx_admin)

    Invoice.delete_all
  end

  # def teardown
  # end

  def test_create_issue()
    mockinvoice = InvoiceStub.new()

    mockinvoice.id = 777
    mockinvoice.file_name = 'sample/testdata.pdf'
    mockinvoice.book_number = 12345
    mockinvoice.organization = @xtrion
    mockinvoice.approver = "abc"

    @jira.create_issue(mockinvoice)

    assert(@mockjira.issue,'Issue should not be empty')
    assert_equal(['testdata.pdf'], @mockjira.filenames)
    assert_equal(['testdata'], @mockjira.filecontents)
  end

  def test_create_issue_with_invalid_assignee()
    mockinvoice = InvoiceStub.new()

    mockinvoice.id = 777
    mockinvoice.file_name = 'sample/testdata.pdf'
    mockinvoice.book_number = 12345
    mockinvoice.organization = @xtrion
    mockinvoice.approver = "DOES NOT EXIST"

    @jira.create_issue(mockinvoice)

    assert(@mockjira.issue,'Issue should not be empty')
    assert_equal(Xtrion_admin, @mockjira.issue.assignee)
    assert_equal(['testdata.pdf'], @mockjira.filenames)
    assert_equal(['testdata'], @mockjira.filecontents)
  end

  def test_create_already_uploaded()
    mockinvoice = InvoiceStub.new()

    mockinvoice.id = 777
    mockinvoice.file_name = 'sample/testdata.pdf'
    mockinvoice.book_number = "pre1 123456"
    mockinvoice.organization = @my_org
    mockinvoice.approver = "abc"

    @jira.create_issue(mockinvoice)
    assert_nil(@mockjira.issue,'Issue should be empty')
  end

  def test_create_issue_for_intercompany_invoice()
    mockinvoice = InvoiceStub.new()

    mockinvoice.id = 777
    mockinvoice.file_name = 'sample/testdata.pdf'
    mockinvoice.book_number = 12345
    mockinvoice.organization = @xtrion
    mockinvoice.approver = "xxx"

    @jira.create_issue(mockinvoice)

    assert(@mockjira.issue,'Issue should not be empty')
    assert_equal(Xtrion_admin, @mockjira.issue.assignee)
    assert_equal(['testdata.pdf'], @mockjira.filenames)
    assert_equal(['testdata'], @mockjira.filecontents)
    assert_equal([2,3], @mockjira.actions)
  end

  def test_create_issue_with_approver
    mockinvoice = InvoiceStub.new()

    mockinvoice.id = 777
    mockinvoice.file_name = 'sample/testdata.pdf'
    mockinvoice.book_number = 12345
    mockinvoice.organization = @melexis
    mockinvoice.approver = 'abc'

    @jira.create_issue(mockinvoice)

    assert_equal(1, @mockjira.issue.status)
    assert_equal('Invoice with booking 12345 for Melexis', @mockjira.issue.summary)
  end

  def test_create_issue_onea_invoice
    mockinvoice = InvoiceStub.new()

    mockinvoice.id = 777
    mockinvoice.file_name = 'sample/12345678.pdf'
    mockinvoice.book_number = '20100826_12345678'
    mockinvoice.organization = @melexis_ieper

    @jira.create_issue(mockinvoice)

    assert_equal(5, @mockjira.issue.status)
    assert_equal(Mlx_admin, @mockjira.issue.assignee)
    assert_equal(['12345678.pdf'], @mockjira.filenames)
    assert_equal('Invoice 20100826_12345678 for Melexis Ieper', @mockjira.issue.summary)
  end

  def test_create_issue_onea_invoice_no_lead_found
    mockinvoice = InvoiceStub.new()

    mockinvoice.id = 777
    mockinvoice.file_name = 'sample/12345678.pdf'
    mockinvoice.book_number = '20100826_12345678'
    mockinvoice.organization = @melexis

    @jira.create_issue(mockinvoice)

    assert_equal(5, @mockjira.issue.status)
    assert_equal(Mlx_admin, @mockjira.issue.assignee)
    assert_equal(['12345678.pdf'], @mockjira.filenames)
    assert_equal('Invoice 20100826_12345678 for Melexis', @mockjira.issue.summary)
    assert_equal('Invoice 20100826_12345678 for Melexis', @mockjira.issue.description)
  end

  # Verify if the proper issuetype id is returned
  def test_get_issuetype
    it = @jira._get_issuetype(INVOICE_TYPE)
    assert_equal(1,it)
  end

  # Verify exception if the invalid issuetype is asked
  def test_get_unknown_issuetype
    e = assert_raises(RuntimeError, "Exception expected when asking for bullshit issuetypes") {
      it = @jira._get_issuetype('DOES_NOT_EXISTS')
    }
    assert_equal(e.message,"Unknown issuetype specified : DOES_NOT_EXISTS")
  end

  # Verify the list of configures components is returned
  def test_get_components
    comps = @jira.components
    assert_equal(comps.size,Components.size,'Components size must match')
    for i in Components
      assert_equal(i, comps[i].name)
    end
  end

  # verify we get the proper component for an existing company
  def test_get_org_components
    org = Components[1]
    comps =  @jira._find_org_components(org)

    assert_equal(1, comps.size)
    assert_equal(org, comps[0].name)
  end

  # verify we get an empty list for an non existing company
  def test_get_org_components
    org = 'NO_SUCH_ORG'
    comps =  @jira._find_org_components(org)

    assert_equal([], comps)
  end

  def test_create_invoice_from_issue
    approver = "abc"
    issue = IssueStub.new(1, "booking 123456 for MyOrg", approver)
    issue.summary = "booking 123456 for MyOrg"
    issue.key = "123"
    issue.status = "6"
    inv = @jira.create_invoice_from_issue(issue)
    assert_equal("123456", inv.book_number)
    assert_equal("abc", inv.approver)
    assert(inv.uploaded)
    assert_equal("dummy", inv.file_name)
    assert_equal("123", inv.jira_id)
    assert_equal("6", inv.jira_status)
  end

  # verify if we can initialise invoice table from Jira
  def test_copy_all_invoice_invoices_from_jira
    @jira.copy_all_invoices_from_jira("")
    invoices = Invoice.order(:book_number).all
    assert_equal(4,invoices.size,"I expected 4 invoices from Jira")

    assert_equal("666666", invoices[0].book_number)
    assert_equal("Organization", invoices[0].organization.name)
    assert_equal("abc", invoices[0].approver)

    assert_equal("765432", invoices[1].book_number)
    assert_equal("Another Org", invoices[1].organization.name)
    assert_equal("abc", invoices[1].approver)

    assert_equal("pre1 123456", invoices[2].book_number)
    assert_equal("My Org", invoices[2].organization.name)
    assert_equal("abc", invoices[2].approver)

    assert_equal("pre2 123456", invoices[3].book_number)
    assert_equal("Another Org", invoices[3].organization.name)
    assert_equal("def", invoices[3].approver)
  end

  def test_add_booking_info
    mockinvoice = InvoiceStub.new()

    mockinvoice.id = 777
    mockinvoice.file_name = '123456.pdf'
    mockinvoice.book_number = 765432
    mockinvoice.organization = @another_org

    @jira.create_issue(mockinvoice)

    booking = BookingStub.new()
    booking.book_number = 765432
    booking.organization = @another_org.name
    booking.uploaded = 0
    @jira.add_booking_info(booking, ['765432', 'supplier', 'amount'])

    assert_equal(["765432", "supplier", "amount"], @mockjira.attributes[0])
    assert booking.uploaded
  end

end
