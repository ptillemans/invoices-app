#!/usr/bin/env ruby1.8
#
#If running as part of distribution
#require File.dirname(__FILE__) + '/../lib/jira4r/jira4r.rb'
#If using GEM install
require 'rubygems'
require 'jira4r/jira_tool'


jira = Jira4R::JiraTool.new(2, "http://issuetrack-stage.melexis.com:8180/jira/rpc/soap/jirasoapservice-v2?wsdl")

jira.login("admin", "system")


#jira.getProjects().each { |project|
#		puts "#{project.name} --> #{project.key}"
#}


  PROJECT = "INVAPP"

  comps = jira.getComponents(PROJECT)
  comps.delete_if { |c| c.name !~ /Elex/ }

  puts "Components :"
  comps.each() { |x| puts "#{x.name} --> #{x.id}" }


  types = jira.getIssueTypes()

  puts "IssueTypes :"
  types.each() { |x| puts "#{x.name} --> #{x.id}" }



issue = Jira4R::V2::RemoteIssue.new()

issue.project = PROJECT
issue.components = comps
issue.summary = "Test Issue"
issue.description = "This is a test issue. Please ignore"
issue.reporter = "admin"
issue.assignee = "juv"
issue.type = "6"

jira.createIssue(issue)

