# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
#
# this file loads seeds based on environments - so please be aware to run appropriate seed file
#
load(Rails.root.join( 'db', 'seeds', "#{Rails.env.downcase}.rb"))
