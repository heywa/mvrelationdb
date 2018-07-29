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

ActiveRecord::Schema.define(version: 20180602125450) do

  create_table "afilinklists", force: :cascade do |t|
    t.string   "afilinkurl"
    t.string   "afilinkasp"
    t.text     "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dmmdvdlists", force: :cascade do |t|
    t.string   "dmmid"
    t.string   "dmmtitle"
    t.string   "series"
    t.string   "maker"
    t.string   "label"
    t.string   "images"
    t.string   "genre"
    t.string   "thumburl"
    t.string   "afiriurl"
    t.string   "sampremovieurl"
    t.string   "sampleumageurl"
    t.string   "actressname"
    t.string   "direcrtorname"
    t.date     "instoredate"
    t.date     "updatedate"
    t.string   "makerid"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "dmmdvdlists", ["dmmid", "dmmtitle"], name: "index_Dmmdvdlists_on_dmmid_and_dmmtitle"

  create_table "dmmlists", force: :cascade do |t|
    t.string   "dmmid"
    t.string   "dmmtitle"
    t.string   "genre"
    t.string   "thumburl"
    t.string   "afiriurl"
    t.string   "sampremovieurl"
    t.string   "sampleumageurl"
    t.string   "actressname"
    t.string   "direcrtorname"
    t.date     "instoredate"
    t.date     "updatedate"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "series"
    t.string   "maker"
    t.string   "label"
    t.string   "images"
  end

  add_index "dmmlists", ["dmmid", "dmmtitle"], name: "index_Dmmlists_on_dmmid_and_dmmtitle"

  create_table "genrerelationlists", force: :cascade do |t|
    t.string   "genrerelationid"
    t.string   "keyword"
    t.string   "medianame"
    t.string   "mvid"
    t.datetime "posteddate"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "relationlists", force: :cascade do |t|
    t.string   "relationid"
    t.string   "frommvid"
    t.string   "tomvid"
    t.string   "fromtitle"
    t.string   "totitle"
    t.date     "updatedate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date     "potdate"
  end

  create_table "smvlists", force: :cascade do |t|
    t.string   "smvid"
    t.string   "smvtitle"
    t.string   "tags"
    t.string   "smvtime"
    t.string   "smvurl"
    t.date     "updatedate"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "smvupdate"
    t.text     "explanation"
    t.string   "thumbnum"
  end

  add_index "smvlists", ["smvid", "smvtitle"], name: "index_Smvlists_on_smvid_and_smvtitle"

  create_table "thisavlists", force: :cascade do |t|
    t.string   "thisavid"
    t.string   "smvtitle"
    t.date     "updatedate"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "thisavtitle"
    t.string   "thisavurl"
    t.string   "tags"
  end

  add_index "thisavlists", ["thisavid", "thisavtitle"], name: "index_Thisavlists_on_thisavid_and_thisavtitle"

  create_table "youflixlists", force: :cascade do |t|
    t.string   "youflixid"
    t.string   "youflixtitle"
    t.string   "tags"
    t.string   "youflixtime"
    t.string   "youflixurl"
    t.date     "updatedate"
    t.string   "youflixupdate"
    t.text     "explanation"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "thumbnum"
  end

  add_index "youflixlists", ["youflixid", "youflixtitle"], name: "index_Youflixlists_on_youflixid_and_youflixtitle"

end
