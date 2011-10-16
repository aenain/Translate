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

ActiveRecord::Schema.define(:version => 20111016144800) do

  create_table "exam_entries", :force => true do |t|
    t.integer  "exam_id"
    t.integer  "question_id"
    t.string   "question_type"
    t.string   "answer_lang"
    t.boolean  "correct"
    t.integer  "position"
    t.integer  "score",         :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "given_answer"
  end

  create_table "exams", :force => true do |t|
    t.integer  "score",      :default => 0
    t.integer  "max_score",  :default => 0
    t.string   "lang"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "translatings", :force => true do |t|
    t.integer  "original_id"
    t.string   "original_type"
    t.integer  "translated_id"
    t.string   "translated_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "words", :force => true do |t|
    t.string   "name"
    t.string   "lang"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "highlight"
  end

end
