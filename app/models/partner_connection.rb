class PartnerConnection < ActiveRecord::Base
  UnknownAuthMechanismError = Class.new(StandardError)

  belongs_to :partner, :counter_cache => true
  belongs_to :connection_type, :counter_cache => true
  has_many :users, :dependent => :destroy

  validates_presence_of :connection_type_id
  validates_uniqueness_of :connection_type_id, :scope => :partner_id

  # Public: Used by ActiveAdmin.
  def display_name
    self.auth_mechanism
  end

  # Public: Return a collection of users that corresponds to the
  # connection type. For example, 'ConnectionType::Plain' gives a
  # collection of 'User::Plain' records.
  def users
    user_type = self.connection_type.type.gsub("ConnectionType::", "User::")
    user_type = user_type.constantize
    user_type.where(:partner_connection_id => self.id, :type => user_type)
  end

  def auth_mechanism
    self.connection_type.auth_mechanism
  end

  # Public: Create a partner connection using the specified auth mechanism.
  def self.for_auth_mechanism(auth_mechanism)
    conn_type = ConnectionType.find_by_auth_mechanism(auth_mechanism)
    raise UnknownAuthMechanismError.new("Unknown auth mechanism: #{auth_mechanism}") if conn_type.nil?
    partner_connection_type = self.connection_type.type.gsub("ConnectionType::", "PartnerConnection::")
    partner_connection_type = user_type.constantize
    scoping do
      partner_connection_type.create(*args, &block)
    end
  end

  # Public: Narrow down a collection of PartnerConnection objects by
  # the auth_mechanism.
  def self.where_auth_mechanism(auth_mechanism)
    conn_type = ConnectionType.find_by_auth_mechanism(auth_mechanism)
    raise UnknownAuthMechanismError.new("Unknown auth mechanism: #{auth_mechanism}") if conn_type.nil?
    if conn_type
      where(:connection_type_id => conn_type.id)
    else
      where("true = false")
    end
  end

  def self.connection_fields
    []
  end

  def connection_fields
    self.class.connection_fields
  end
end
