class Group < ActiveRecord::Base
  has_many :group_associations
  has_many :users, through: :group_associations

  has_many :host_access_groups
  has_many :host_machines, through: :host_access_groups
  acts_as_paranoid


  after_create :add_gid

  GID_CONSTANT = 9000

  def add_gid
    self.gid = self.id + GID_CONSTANT
    self.save!
  end

  def self.get_name_response name
    group = Group.where(name: name).first
    return [] if group.blank?

    group.group_response
  end

  def self.get_all_response
    response_array = []
    Group.all.each do |group|
      response_array << group.group_response
    end
    response_array
  end

  def self.response_array group_response
    response_array = []
    response_array <<  group_response
    response_array
  end

  def self.get_gid_response gid
    group = Group.where(gid: gid).first
    return [] if group.blank?
    group.group_response
  end

  def group_response
    response_hash = {}
    response_hash[:gr_name] = name
    response_hash[:gr_passwd] = "x"
    response_hash[:gr_gid] = gid
    response_hash[:gr_mem] = users.collect { |u| u.get_user_unix_name}
    response_hash

  end
end
