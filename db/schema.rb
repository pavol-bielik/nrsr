# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100507191643) do

  create_table "deputies", :force => true do |t|
    t.string   "degree"
    t.string   "lastname"
    t.string   "firstname"
    t.string   "party"
    t.datetime "born"
    t.string   "nationality"
    t.string   "domicile"
    t.string   "region"
    t.string   "email"
    t.string   "contact_person"
    t.string   "photo"
  end

  add_index "deputies", ["id"], :name => "index_deputies_on_id", :unique => true

  create_table "statutes", :force => true do |t|
    t.integer "parent_id"
    t.string  "statute_type"
    t.string  "state"
    t.string  "result"
    t.text    "subject"
    t.date    "date"
    t.string  "doc"
  end

  create_table "votes", :force => true do |t|
    t.integer "voting_id"
    t.integer "deputy_id"
    t.string  "vote",      :limit => 10
    t.string  "party",     :limit => 100
  end

  add_index "votes", ["deputy_id"], :name => "index_votes_on_deputy_id"
  add_index "votes", ["id"], :name => "index_votes_on_id", :unique => true
  add_index "votes", ["voting_id"], :name => "index_votes_on_voting_id"

  create_table "votings", :force => true do |t|
    t.integer  "statute_id"
    t.text     "subject"
    t.integer  "meeting_no"
    t.integer  "voting_no"
    t.datetime "happened_at"
    t.integer  "attending_count",     :limit => 3, :precision => 3, :scale => 0
    t.integer  "voting_count",        :limit => 3, :precision => 3, :scale => 0
    t.integer  "pro_count",           :limit => 3, :precision => 3, :scale => 0
    t.integer  "against_count",       :limit => 3, :precision => 3, :scale => 0
    t.integer  "hold_count",          :limit => 3, :precision => 3, :scale => 0
    t.integer  "not_voting_count",    :limit => 3, :precision => 3, :scale => 0
    t.integer  "not_attending_count", :limit => 3, :precision => 3, :scale => 0
    t.integer  "popularity"
  end

  add_index "votings", ["popularity"], :name => "index_votings_on_popularity"
  add_index "votings", ["statute_id"], :name => "index_votings_on_statute_id"

end
