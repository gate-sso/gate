class Group < ActiveRecord::Base
  has_paper_trail

  has_many :group_admins, dependent: :destroy
  has_many :group_associations
  has_many :users, through: :group_associations

  has_many :vpn_group_associations
  has_many :vpns, through: :vpn_group_associations

  has_many :host_access_groups
  has_many :host_machines, through: :host_access_groups
  belongs_to :vpn

  validates_uniqueness_of :name, case_sensitive: false

  before_create :set_lower_case_name
  acts_as_paranoid

  after_create :add_gid

  GID_CONSTANT = 9000

  def add_admin user
      GroupAdmin.find_or_create_by(group_id: id, user: user)
  end

  def set_lower_case_name
    self.name = self.name.downcase
  end

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

  def admin? user
    GroupAdmin.where(group_id: self, user_id: user).first.present?
  end

  def member? user
    users.exists? user.id
  end

  def group_response
    response_hash = {}
    response_hash[:gr_name] = name
    response_hash[:gr_passwd] = "x"
    response_hash[:gr_gid] = gid
    response_hash[:gr_mem] = users.collect { |u| u.user_login_id}
    response_hash
  end
end
