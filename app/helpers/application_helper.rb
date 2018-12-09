module ApplicationHelper
  def add_placeholder_to_list(list, placeholder, string_convert: 'titleize')
    (list.map do |row|
      name = string_convert.present? ? row.send(string_convert.to_sym) : row
      [name, row]
    end).insert(0, [placeholder, ''])
  end
end
