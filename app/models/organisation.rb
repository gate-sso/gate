class Organisation < ActiveRecord::Base
  validates :name, :website, :domain, :country, :state, :address,
            :admin_email_address, :slug, presence: true
  validates :admin_email_address, email: true
  validates :slug, uniqueness: true

  UPDATE_KEYS = %w(
    name website domain country state address admin_email_address slug unit_name
  ).freeze

  def self.setup(attrs = {})
    attrs = attrs.stringify_keys
    attrs = attrs.select { |k, _v| UPDATE_KEYS.include?(k) }
    org = Organisation.new(attrs)
    org.save if org.valid?
    org
  end

  def update_profile(attrs = {})
    attrs = attrs.stringify_keys
    attrs = attrs.select { |k, _v| UPDATE_KEYS.include?(k) }
    assign_attributes(attrs)
    save if valid?
  end
end
