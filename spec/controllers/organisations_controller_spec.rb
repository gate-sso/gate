require 'rails_helper'

describe OrganisationsController, type: :controller do
  let(:valid_attributes) do
    {
      name: 'name',
      website: 'sample.com',
      domain: 'sample.com',
      country: 'ID',
      state: 'DKI Jakarta',
      address: 'Jl Iskandarsyah II',
      admin_email_address: 'admin@gate.com',
      unit_name: 'system'
    }
  end

  let(:new_attributes) do
    {
      name: 'new_name',
      website: 'new_sample.com',
      domain: 'new_sample.com',
      country: 'new_ID',
      state: 'new_DKI Jakarta',
      address: 'new Jl Iskandarsyah II',
      admin_email_address: 'new_admin@gate.com',
      unit_name: 'new_system'
    }
  end

  describe 'PATCH #update' do
    context 'authenticated as admin' do
      it 'should update requested organisations' do
        organisation = create(:organisation, valid_attributes)
        admin = create(:user)
        sign_in admin
        patch :update, params: { id: organisation.id, organisation: new_attributes }
        organisation.reload
        updated_organisation_data = {
          name: organisation.name,
          website: organisation.website,
          domain: organisation.domain,
          country: organisation.country,
          state: organisation.state,
          address: organisation.address,
          admin_email_address: organisation.admin_email_address,
          unit_name: organisation.unit_name
        }
        expect(updated_organisation_data.to_json). to eq(new_attributes.to_json)
      end
    end

    context 'authenticated as non admin' do
      it 'should not update requested organisation' do
        create(:user)
        non_admin = create(:user, admin: false)
        sign_in non_admin
        organisation = create(:organisation, valid_attributes)
        patch :update, params: { id: organisation.id, organisation: new_attributes }
        organisation.reload
        updated_organisation_data = {
          name: organisation.name,
          website: organisation.website,
          domain: organisation.domain,
          country: organisation.country,
          state: organisation.state,
          address: organisation.address,
          admin_email_address: organisation.admin_email_address,
          unit_name: organisation.unit_name
        }
        expect(updated_organisation_data.to_json).to eq(valid_attributes.to_json)
      end
    end
  end
end
