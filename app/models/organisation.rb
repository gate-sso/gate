class Organisation < ActiveRecord::Base
  validates :name, :url, :email_domain, presence: true

  def self.setup(attrs = {})
    attrs.stringify_keys!
    attrs = attrs.select { |k, _v| %w(name url email_domain).include?(k) }
    org = Organisation.new(attrs)
    org.save if org.valid?
    org
  end

  def update_profile(attrs = {})
    attrs.stringify_keys!
    attrs = attrs.select { |k, _v| %w(name url email_domain).include?(k) }
    assign_attributes(attrs)
    save if valid?
  end
end
