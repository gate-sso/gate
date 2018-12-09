require 'rails_helper'

describe ApplicationHelper, type: :helper do
  describe '.add_placeholder_to_list' do
    let (:placeholder) { 'placeholder' }
    let(:list) { (1..5).map { |ix| "row#{ix}" } }

    it 'returns list with first element of every array titleized and adds placeholder' do
      titleized_list = list.map { |row| [row.titleize, row] }.insert(0, [placeholder, ''])
      expect(helper.add_placeholder_to_list(list, placeholder)).to eq(titleized_list)
    end

    it 'returns list with first element of every array with string function and adds placeholder' do
      titleized_list = list.map { |row| [row.capitalize, row] }.insert(0, [placeholder, ''])
      expect(helper.add_placeholder_to_list(list, placeholder, string_convert: 'capitalize')).to eq(titleized_list)
    end

  end
end
