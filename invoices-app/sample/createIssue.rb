require 'rubygems'
require 'jira4r/jira_tool'

jira = Jira4R::JiraTool.new(2, "http://issuetrack-stage.melexis.com:8180/jira/rpc/soap/jirasoapservice-v2?wsdl")

jira.login("admin", "system")


#jira.getProjects().each { |project|
#		puts "#{project.name} --> #{project.key}"
#}


PROJECT = "INVAPP"
INVOICE_TYPE = "Invoice"

def createIssue(invoice, scanfile) 
	
	puts "Handling invoice #{invoice.id}"
	
	comps = jira.getComponents(PROJECT)
	comps.delete_if { |c| c.name !~ Regexp.new(invoice.organization) }

	puts "Components :"
	comps.each() { |x| puts "#{x.name} --> #{x.id}" }


	types = jira.getIssueTypes()

	
	issuetype = 0
	types.each() { |x| issuetype = x.id if x.name == INVOICE_TYPE }
	
	puts "IssueTypes : #{issuetype}"
	
	issue = Jira4R::V2::RemoteIssue.new()

	issue.project = PROJECT
	issue.components = comps
	issue.summary = "Test Issue"
	issue.description = "This is a test issue. Please ignore"
	issue.reporter = "admin"
	issue.assignee = "tbb"
	issue.type = issuetype

	issue = jira.createIssue(issue)
	
	puts "Created ticket : issue.key"
	
	filenames = [ scanfile]
	bytes = SOAP::SOAPBase64.new(File.read(filename))
	filecontents = [ bytes ]


	jira.addAttachmentsToIssue(issue.key, filenames, filecontents);

end

