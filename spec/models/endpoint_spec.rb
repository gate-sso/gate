require 'rails_helper'

describe Endpoint, type: :model do
  describe 'validations' do
    describe 'path' do
      context 'when given nil path' do
        it 'should not valid' do
          endpoint = build(:endpoint, path: nil)
          expect(endpoint).not_to be_valid
        end
      end

      context 'when given path with parameter' do
        it 'should valid' do
          endpoint = build(:endpoint, path: '/users/:id')
          expect(endpoint).to be_valid
        end
      end

      context 'when given invalid path' do
        it 'should not valid' do
          endpoint = build(:endpoint, path: '/users/::id')
          expect(endpoint).not_to be_valid
        end
      end

      context 'when given path ended with /' do
        it 'should not valid' do
          endpoint = build(:endpoint, path: '/users/')
          expect(endpoint).not_to be_valid
        end
      end
    end

    describe 'method' do
      context 'when given nil method' do
        it 'should not valid' do
          endpoint = build(:endpoint, method: nil)
          expect(endpoint).not_to be_valid
        end
      end

      context 'when given unknown method' do
        it 'should not valid' do
          endpoint = build(:endpoint, method: 'JUMP')
          expect(endpoint).not_to be_valid
        end
      end
    end
  end
end
