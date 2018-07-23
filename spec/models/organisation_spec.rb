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
end
