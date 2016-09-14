class HostMachine < ActiveRecord::Base
  has_many :host_machine_groups
  has_many :users, through: :host_machine_groups
  validates_uniqueness_of :name, case_sensitive: false

  before_create :set_lower_case_name

  def set_lower_case_name
    self.name = self.name.downcase
  end

end
