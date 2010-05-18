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

ActiveRecord::Schema.define(:version => 20100509150147) do

  create_table "deputies", :force => true do |t|
    t.string "degree"
    t.string "lastname"
    t.string "firstname"
    t.string "elected_for"
    t.string "party"
    t.date   "party_since"
    t.date   "born"
    t.string "nationality"
    t.string "domicile"
    t.string "region"
    t.string "email"
    t.string "contact_person"
    t.string "photo"
  end

  add_index "deputies", ["id"], :name => "index_deputies_on_id", :unique => true

  create_table "deputy_relations", :force => true do |t|
    t.integer "deputy1_id"
    t.integer "deputy2_id"
    t.integer "relation",   :default => 0
    t.integer "votes",      :default => 0
  end

  add_index "deputy_relations", ["deputy1_id", "deputy2_id"], :name => "index_deputy_relations_on_deputy1_id_and_deputy2_id", :unique => true
  add_index "deputy_relations", ["id"], :name => "index_deputy_relations_on_id", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "statutes", :force => true do |t|
    t.integer "parent_id"
    t.string  "statute_type"
    t.string  "state"
    t.string  "result"
    t.text    "subject"
    t.string  "short_subject"
    t.date    "date"
    t.string  "doc"
    t.integer "popularity"
    t.text    "info"
  end

  create_table "user_relations", :force => true do |t|
    t.integer "user_id"
    t.integer "deputy_id"
    t.integer "relation",  :default => 0
    t.integer "votes",     :default => 0
  end

  add_index "user_relations", ["id"], :name => "index_user_relations_on_id", :unique => true
  add_index "user_relations", ["user_id", "deputy_id"], :name => "index_user_relations_on_user_id_and_deputy_id", :unique => true

  create_table "user_votes", :force => true do |t|
    t.integer "voting_id"
    t.integer "user_id"
    t.string  "vote",      :limit => 10
  end

  add_index "user_votes", ["id"], :name => "index_user_votes_on_id", :unique => true
  add_index "user_votes", ["user_id"], :name => "index_user_votes_on_user_id"
  add_index "user_votes", ["voting_id"], :name => "index_user_votes_on_voting_id"

  create_table "users", :force => true do |t|
    t.string   "login",             :null => false
    t.string   "crypted_password",  :null => false
    t.string   "password_salt",     :null => false
    t.string   "persistence_token", :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
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
    t.string   "short_subject"
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
    t.text     "info"
  end

  add_index "votings", ["popularity"], :name => "index_votings_on_popularity"
  add_index "votings", ["statute_id"], :name => "index_votings_on_statute_id"

end
