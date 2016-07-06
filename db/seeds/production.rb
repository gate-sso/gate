# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
group = Group.where(name: "people").first
group = Group.create(name: "people") if group.blank?

group = Group.where(name: "devops").first
group = Group.create(name: "devops") if group.blank?
