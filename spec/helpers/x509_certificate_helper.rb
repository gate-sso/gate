class CertificateHelper
  def initialize
    @key = OpenSSL::PKey::RSA.new(1024)
    @public_key = @key.public_key

    subject = "/C=BE/O=Test/OU=Test/CN=Test"

    @cert = OpenSSL::X509::Certificate.new
    @cert.subject = @cert.issuer = OpenSSL::X509::Name.parse(subject)
    @cert.not_before = Time.now
    @cert.not_after = Time.now + 1 * 24 * 60 * 60
    @cert.public_key = @public_key
    @cert.serial = 0x0
    @cert.version = 2

    @cert.sign @key, OpenSSL::Digest::SHA256.new
  end

  def get_cert
    @cert.to_pem
  end

  def get_private_key
    @key.to_s
  end

  def get_fingerprint
    OpenSSL::Digest::SHA256.new(@cert.to_der).to_s
  end

end

