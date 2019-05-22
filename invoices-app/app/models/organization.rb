require 'active_record'

class Organization < ActiveRecord::Base

  validates_uniqueness_of :name
  serialize :backends, Array

  def Organization.by_name(organization)
    org=Organization.where(name: organization).first
    return org
  end

  def to_s
    return @name
  end

  def invoices
    Invoice.where(organization: self).order(created_at: :desc).all
  end

end
