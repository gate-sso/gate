class Organisation < ActiveRecord::Base
  validates :name, :website, :domain, :country, :state, :address,
            :admin_email_address, :slug, presence: true
  validates :address, format: {
    with: /\A[a-zA-Z0-9\s]+\z/,
    message: 'Invalid - Only Alphabets, Space and Numbers Allowed',
  }
  validates :admin_email_address, email: true
  validates :slug, uniqueness: true

  attr_accessor :cert, :rsa_key

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

  def saml_setup?
    cert_fingerprint.present? && cert_key.present? && cert_private_key.present?
  end

  def setup_saml_certs
    return false unless persisted?
    require 'openssl'
    self.rsa_key = OpenSSL::PKey::RSA.new(2048)
    private_key = rsa_key.to_pem
    public_key = rsa_key.public_key
    subject = "/C=#{country}/ST=#{state}/L=#{address}/O=#{name}/OU=#{unit_name}/CN=#{domain}"
    self.cert = OpenSSL::X509::Certificate.new
    cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
    cert.not_before = Time.now
    cert.not_after = Time.now + 365 * 24 * 60 * 60
    cert.public_key = public_key
    cert.serial = SecureRandom.random_number(10)
    cert.version = 2
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = cert
    cert.extensions = [
      ef.create_extension('basicConstraints', 'CA:TRUE', true),
      ef.create_extension('subjectKeyIdentifier', 'hash'),
    ]
    cert.add_extension ef.create_extension(
      'authorityKeyIdentifier', 'keyid:always,issuer:always'
    )
    cert.sign rsa_key, OpenSSL::Digest::SHA1.new
    update_attributes(
      cert_fingerprint: OpenSSL::Digest::SHA256.hexdigest(cert.to_der).scan(/../).join(':'),
      cert_key: cert.to_pem,
      cert_private_key: private_key
    )
  end
end
