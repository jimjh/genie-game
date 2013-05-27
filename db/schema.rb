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

ActiveRecord::Schema.define(:version => 20130527130337) do

  create_table "answers", :force => true do |t|
    t.integer  "problem_id"
    t.integer  "user_id"
    t.binary   "content",    :limit => 255
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "results",                   :default => "", :null => false
    t.integer  "score",                     :default => 0,  :null => false
  end

  add_index "answers", ["problem_id"], :name => "index_answers_on_problem_id"
  add_index "answers", ["user_id"], :name => "index_answers_on_user_id"

  create_table "authorizations", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.string   "token"
    t.string   "secret"
    t.string   "name"
    t.string   "link"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "nickname"
  end

  add_index "authorizations", ["user_id"], :name => "index_authorizations_on_user_id"

  create_table "lessons", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "url"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "slug"
    t.string   "hook"
    t.string   "compiled_path"
    t.string   "status",        :default => "publishing", :null => false
    t.string   "title"
    t.text     "description"
  end

  add_index "lessons", ["slug"], :name => "index_lessons_on_slug", :unique => true
  add_index "lessons", ["user_id"], :name => "index_lessons_on_user_id"

  create_table "problems", :force => true do |t|
    t.binary   "digest",     :limit => 255,                   :null => false
    t.integer  "position",                                    :null => false
    t.integer  "lesson_id",                                   :null => false
    t.binary   "solution"
    t.boolean  "active",                    :default => true
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "problems", ["digest"], :name => "index_questions_on_digest"
  add_index "problems", ["lesson_id"], :name => "index_questions_on_lesson_id"
  add_index "problems", ["position"], :name => "index_questions_on_position"

  create_table "users", :force => true do |t|
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "slug"
  end

  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true

end
