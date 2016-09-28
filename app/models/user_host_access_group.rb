class UserHostAccessGroup < ActiveRecord::Base
  belongs_to :user
  belongs_to :host_access_group
end
