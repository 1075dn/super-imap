class Partner < ActiveRecord::Base
  # Magic.
  before_save :ensure_api_key

  # Relations
  has_many :partner_connections, :dependent => :destroy
  alias_method :connections, :partner_connections

  # Validations
  validates :name, :presence => true

  def ensure_api_key
    self.api_key ||= SecureRandom.hex(10)
  end

  # Public: Create a new connection that bases it's type on the
  # provided imap_provider. In other words, if this is an
  # Oauth2::ImapProvider, then return an Oauth2::ImapProvider.
  def new_typed_connection(imap_provider)
    connection = imap_provider.class_for(PartnerConnection).new
    self.connections << connection
    connection
  end
end
