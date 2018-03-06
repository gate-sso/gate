class HostMachine < ActiveRecord::Base
  has_paper_trail

  has_many :host_access_groups
  has_many :groups, through: :host_access_groups
  validates_uniqueness_of :name, case_sensitive: false

  before_create :set_lower_case_name
  before_save :set_host_access_key
  before_create :set_host_access_key

  def set_host_access_key
    self.access_key = ROTP::Base32.random_base32 
  end

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

  def sysadmins
    users = []
    groups.each do |group|
      users = users + group.users.collect{|u| u.id}
    end
    group = Group.find_by(name: "sysadmins")
    users = users + group.users.collect{|u| u.id} if group.present?
    users.uniq
  end

end
