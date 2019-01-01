class HostMachine < ApplicationRecord
  has_paper_trail

  has_many :host_access_groups
  has_many :groups, through: :host_access_groups
  validates_uniqueness_of :name, case_sensitive: false
  validates :name, presence: true

  before_create :set_lower_case_name
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
    users = GroupAssociation.
      select(:user_id).
      distinct.
      joins(:user).
      where("group_id IN (?)", groups.collect(&:id)).
      collect(&:user_id)
  end

  def add_host_group(name)
    name = name.squish
    if name.present?
      name = "#{name}_host_group"
      self.add_group(name.downcase)
    end
  end

  def add_group(name)
    name = name.squish
    if name.present?
      group =  Group.find_or_initialize_by(name: name.downcase)
      self.groups << group unless self.groups.include? group
      self.save
    end
  end
end
