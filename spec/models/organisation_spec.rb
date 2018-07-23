require 'rails_helper'

RSpec.describe Organisation, type: :model do
  describe '.setup' do
    let(:org_data) { attributes_for(:organisation) }
    it 'should create organisation' do
      org = Organisation.setup(org_data)
      org_data.each do |key, value|
        expect(org.send(key.to_sym)).to eq(value)
      end
      expect(org.persisted?).to eq(true)
      expect(org.valid?).to eq(true)
    end

    it 'should not create organisation if validations fail' do
      org = Organisation.setup(name: org_data[:name])
      expect(org.persisted?).to eq(false)
      expect(org.valid?).to eq(false)
      expect(org.errors.messages.key?(:website)).to eq(true)
      expect(org.errors.messages.key?(:domain)).to eq(true)
    end
  end

  describe '.update_profile' do
    let(:org) { create(:organisation) }
    let(:org_data) { attributes_for(:organisation) }
    it 'should update organisation profile' do
      org.update_profile(org_data)
      org_data.each do |key, value|
        expect(org.send(key.to_sym)).to eq(value)
      end
      expect(org.valid?).to eq(true)
    end

    it 'shouldn not update organisation profile if validations fail' do
      org.update_profile(name: '')
      expect(org.valid?).to eq(false)
      expect(org.errors.messages.key?(:name)).to eq(true)
    end
  end

  describe '.setup_saml_certs' do
    let(:org) { create(:organisation) }
    it 'should set the subject based on organisation profile' do
      org.setup_saml_certs
      subject = Hash[org.cert.subject.to_a.map { |i| [i[0].to_sym, i[1]] }]
      expected_subject = {
        C: org.country, ST: org.state, L: org.address, O: org.name, OU: org.unit_name,
        CN: org.domain
      }
      expect(subject).to eq(expected_subject)
    end

    it 'should set the expiry of the certificate for 1 year' do
      org.setup_saml_certs
      Timecop.freeze(Time.now - 10.minutes)
      expect(org.cert.not_before > Time.now).to eq(true)
      expect(org.cert.not_after > Time.now + 365 * 24 * 60 * 60).to eq(true)
    end

    it 'should update the certificate for the organisation' do
      org.setup_saml_certs
      fingerprint = OpenSSL::Digest::SHA256.hexdigest(org.cert.to_der).scan(/../).join(':')
      private_key = org.rsa_key.to_pem
      cert = org.cert.to_pem
      expect(org.cert_fingerprint).to eq(fingerprint)
      expect(org.cert_private_key).to eq(private_key)
      expect(org.cert_key).to eq(cert)
    end
  end

  describe '.saml_setup?' do
    let(:org) { create(:organisation) }
    it 'should return true if saml is setup' do
      org.setup_saml_certs
      expect(org.saml_setup?).to eq(true)
    end
  end
end
