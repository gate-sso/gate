class HostMachine < ActiveRecord::Base
  has_many :host_access_groups
  has_many :groups, through: :host_access_groups
  validates_uniqueness_of :name, case_sensitive: false

  before_create :set_lower_case_name

  def set_lower_case_name
    self.name = self.name.downcase
  end

  def self.get_group_response name
    host_machine = HostMachine.find_by_name(name)
    response = {}
    return response if host_machine.blank?
    response[:host_name] = name
    response[:groups] = host_machine.groups.collect { |g| g.name }
    response
  end

end
