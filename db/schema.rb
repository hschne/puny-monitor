# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 20_240_930_155_845) do
  create_table "bandwidths", force: :cascade do |t|
    t.float "incoming_mbps"
    t.float "outgoing_mbps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_bandwidths_on_created_at"
  end

  create_table "cpu_loads", force: :cascade do |t|
    t.float "one_minute"
    t.float "five_minutes"
    t.float "fifteen_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_cpu_loads_on_created_at"
  end

  create_table "cpu_usages", force: :cascade do |t|
    t.float "used_percent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_cpu_usages_on_created_at"
  end

  create_table "disk_ios", force: :cascade do |t|
    t.float "read_mb_per_sec"
    t.float "write_mb_per_sec"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_disk_ios_on_created_at"
  end

  create_table "filesystem_usages", force: :cascade do |t|
    t.float "used_percent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_filesystem_usages_on_created_at"
  end

  create_table "memory_usages", force: :cascade do |t|
    t.float "used_percent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_memory_usages_on_created_at"
  end
end
