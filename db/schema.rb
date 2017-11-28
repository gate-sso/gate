# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20171124115925) do

  create_table "access_tokens", force: :cascade do |t|
    t.string   "token",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id",    limit: 4
  end

  add_index "access_tokens", ["user_id"], name: "fk_rails_96fc070778", using: :btree

  create_table "group_admins", force: :cascade do |t|
    t.integer  "group_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_admins", ["group_id"], name: "fk_rails_1a1d29d2d3", using: :btree
  add_index "group_admins", ["user_id"], name: "fk_rails_0ac5a6fa32", using: :btree

  create_table "group_associations", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "group_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "gid",        limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "deleted_by", limit: 4
    t.datetime "deleted_at"
  end

  add_index "groups", ["name"], name: "index_groups_on_name", unique: true, using: :btree

  create_table "host_access_groups", force: :cascade do |t|
    t.integer  "host_machine_id", limit: 4
    t.integer  "group_id",        limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "host_machines", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "hosts", force: :cascade do |t|
    t.string   "host_pattern", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "user_id",      limit: 4
    t.datetime "deleted_at"
    t.integer  "deleted_by",   limit: 4
  end

  add_index "hosts", ["deleted_at"], name: "index_hosts_on_deleted_at", using: :btree
  add_index "hosts", ["deleted_by"], name: "index_hosts_on_deleted_by", using: :btree
  add_index "hosts", ["host_pattern"], name: "index_hosts_on_host_pattern", using: :btree
  add_index "hosts", ["user_id"], name: "index_hosts_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "",    null: false
    t.string   "encrypted_password",     limit: 255,   default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "name",                   limit: 255
    t.string   "auth_key",               limit: 255
    t.string   "provisioning_uri",       limit: 255
    t.boolean  "active",                               default: true
    t.boolean  "admin",                                default: false
    t.string   "home_dir",               limit: 255
    t.string   "shell",                  limit: 255
    t.text     "public_key",             limit: 65535
    t.string   "user_login_id",          limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["user_login_id"], name: "index_users_on_user_login_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 191,        null: false
    t.integer  "item_id",        limit: 4,          null: false
    t.string   "event",          limit: 255,        null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object",         limit: 4294967295
    t.text     "object_changes", limit: 65535
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "vpn_domain_name_servers", force: :cascade do |t|
    t.integer  "vpn_id",         limit: 4
    t.string   "server_address", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vpn_group_associations", force: :cascade do |t|
    t.integer  "group_id",   limit: 4
    t.integer  "vpn_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vpn_group_associations", ["group_id"], name: "fk_rails_67a460ac90", using: :btree
  add_index "vpn_group_associations", ["vpn_id"], name: "fk_rails_9be3690c1d", using: :btree

  create_table "vpn_group_user_associations", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "vpn_id",     limit: 4
    t.integer  "group_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vpn_group_user_associations", ["group_id"], name: "fk_rails_30de0bd58e", using: :btree
  add_index "vpn_group_user_associations", ["user_id"], name: "fk_rails_275419a627", using: :btree
  add_index "vpn_group_user_associations", ["vpn_id"], name: "fk_rails_dbd29a5c87", using: :btree

  create_table "vpn_search_domains", force: :cascade do |t|
    t.integer  "vpn_id",        limit: 4
    t.string   "search_domain", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vpn_supplemental_match_domains", force: :cascade do |t|
    t.integer  "vpn_id",                    limit: 4
    t.string   "supplemental_match_domain", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vpns", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "host_name",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address", limit: 255
    t.string   "uuid",       limit: 255
  end

  add_foreign_key "access_tokens", "users"
  add_foreign_key "group_admins", "groups"
  add_foreign_key "group_admins", "users"
  add_foreign_key "hosts", "users"
  add_foreign_key "vpn_group_associations", "groups"
  add_foreign_key "vpn_group_associations", "vpns"
  add_foreign_key "vpn_group_user_associations", "groups"
  add_foreign_key "vpn_group_user_associations", "users"
  add_foreign_key "vpn_group_user_associations", "vpns"
end
