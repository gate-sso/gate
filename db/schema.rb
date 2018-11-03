# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181016093315) do

  create_table "access_tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "hashed_token"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
    t.index ["hashed_token"], name: "index_access_tokens_on_hashed_token", using: :btree
    t.index ["user_id"], name: "fk_rails_96fc070778", using: :btree
  end

  create_table "api_resources", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "description"
    t.string   "hashed_access_key"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "user_id"
    t.integer  "group_id"
    t.index ["group_id"], name: "index_api_resources_on_group_id", using: :btree
    t.index ["user_id"], name: "index_api_resources_on_user_id", using: :btree
  end

  create_table "group_admins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id"], name: "fk_rails_1a1d29d2d3", using: :btree
    t.index ["user_id"], name: "fk_rails_0ac5a6fa32", using: :btree
  end

  create_table "group_associations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "user_id"], name: "index_group_associations_on_group_id_and_user_id", using: :btree
  end

  create_table "groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "gid"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "deleted_by"
    t.datetime "deleted_at"
    t.string   "description"
    t.index ["gid"], name: "index_groups_on_gid", using: :btree
    t.index ["name"], name: "index_groups_on_name", unique: true, using: :btree
  end

  create_table "host_access_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "host_machine_id"
    t.integer  "group_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["host_machine_id", "group_id"], name: "index_host_access_groups_on_host_machine_id_and_group_id", using: :btree
  end

  create_table "host_machines", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "api_key"
    t.string   "access_key"
    t.boolean  "default_admins", default: true
    t.index ["access_key"], name: "index_host_machines_on_access_key", using: :btree
  end

  create_table "hosts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "host_pattern"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.integer  "deleted_by"
    t.index ["deleted_at"], name: "index_hosts_on_deleted_at", using: :btree
    t.index ["deleted_by"], name: "index_hosts_on_deleted_by", using: :btree
    t.index ["host_pattern"], name: "index_hosts_on_host_pattern", using: :btree
    t.index ["user_id"], name: "index_hosts_on_user_id", using: :btree
  end

  create_table "ip_addresses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "address"
    t.string   "mac_address"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "host_machine_id"
    t.index ["address"], name: "index_ip_addresses_on_address", using: :btree
    t.index ["host_machine_id"], name: "index_ip_addresses_on_host_machine_id", using: :btree
    t.index ["mac_address"], name: "index_ip_addresses_on_mac_address", using: :btree
  end

  create_table "organisations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "website"
    t.string   "domain"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "country"
    t.string   "state"
    t.string   "address"
    t.string   "unit_name"
    t.string   "admin_email_address"
    t.string   "slug"
    t.string   "cert_fingerprint"
    t.text     "cert_key",            limit: 65535
    t.text     "cert_private_key",    limit: 65535
  end

  create_table "saml_app_configs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "group_id"
    t.string   "sso_url"
    t.json     "config"
    t.integer  "organisation_id"
    t.string   "app_name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["group_id"], name: "index_saml_app_configs_on_group_id", using: :btree
    t.index ["organisation_id"], name: "index_saml_app_configs_on_organisation_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                                default: "",    null: false
    t.string   "encrypted_password",                   default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "auth_key"
    t.string   "provisioning_uri"
    t.boolean  "active",                               default: true
    t.boolean  "admin",                                default: false
    t.string   "home_dir"
    t.string   "shell"
    t.text     "public_key",             limit: 65535
    t.string   "user_login_id"
    t.string   "product_name"
    t.string   "access_key"
    t.datetime "deactivated_at"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["uid"], name: "index_users_on_uid", using: :btree
    t.index ["user_login_id"], name: "index_users_on_user_login_id", using: :btree
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string   "item_type",      limit: 191,        null: false
    t.integer  "item_id",                           null: false
    t.string   "event",                             null: false
    t.string   "whodunnit"
    t.text     "object",         limit: 4294967295
    t.text     "object_changes", limit: 65535
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  create_table "vpn_domain_name_servers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "vpn_id"
    t.string   "server_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vpn_group_associations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "group_id"
    t.integer  "vpn_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id"], name: "fk_rails_67a460ac90", using: :btree
    t.index ["vpn_id"], name: "fk_rails_9be3690c1d", using: :btree
  end

  create_table "vpn_group_user_associations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "vpn_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id"], name: "fk_rails_30de0bd58e", using: :btree
    t.index ["user_id"], name: "fk_rails_275419a627", using: :btree
    t.index ["vpn_id"], name: "fk_rails_dbd29a5c87", using: :btree
  end

  create_table "vpn_search_domains", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "vpn_id"
    t.string   "search_domain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vpn_supplemental_match_domains", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "vpn_id"
    t.string   "supplemental_match_domain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vpns", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "host_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address"
    t.string   "uuid"
  end

  add_foreign_key "access_tokens", "users"
  add_foreign_key "api_resources", "groups"
  add_foreign_key "api_resources", "users"
  add_foreign_key "group_admins", "groups"
  add_foreign_key "group_admins", "users"
  add_foreign_key "hosts", "users"
  add_foreign_key "ip_addresses", "host_machines"
  add_foreign_key "saml_app_configs", "groups"
  add_foreign_key "saml_app_configs", "organisations"
  add_foreign_key "vpn_group_associations", "groups"
  add_foreign_key "vpn_group_associations", "vpns"
  add_foreign_key "vpn_group_user_associations", "groups"
  add_foreign_key "vpn_group_user_associations", "users"
  add_foreign_key "vpn_group_user_associations", "vpns"
end
