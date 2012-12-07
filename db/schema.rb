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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121207064249) do

  create_table "achievements", :force => true do |t|
    t.integer  "player_id"
    t.string   "title"
    t.text     "description"
    t.string   "badge"
    t.string   "type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "match_id"
  end

  create_table "daily_logs", :force => true do |t|
    t.float    "average_games_per_player"
    t.integer  "match_count"
    t.date     "date"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "logs", :force => true do |t|
    t.integer  "player_id"
    t.integer  "match_id"
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "matches", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "occured_at"
    t.integer  "winner_id"
    t.integer  "loser_id"
  end

  create_table "players", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rank"
    t.boolean  "active",     :default => true
    t.string   "avatar"
  end

end
