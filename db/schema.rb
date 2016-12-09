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

ActiveRecord::Schema.define(version: 20161209205613) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.integer  "exercise_class_id"
    t.integer  "user_id"
    t.datetime "date"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["exercise_class_id"], name: "index_attendances_on_exercise_class_id", using: :btree
    t.index ["user_id"], name: "index_attendances_on_user_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exercise_class_attributes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exercise_classes", force: :cascade do |t|
    t.integer  "studio_id"
    t.integer  "category_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["category_id"], name: "index_exercise_classes_on_category_id", using: :btree
    t.index ["studio_id"], name: "index_exercise_classes_on_studio_id", using: :btree
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "exercise_class_id"
    t.integer  "exercise_class_attribute_id"
    t.integer  "score"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["exercise_class_attribute_id"], name: "index_ratings_on_exercise_class_attribute_id", using: :btree
    t.index ["exercise_class_id"], name: "index_ratings_on_exercise_class_id", using: :btree
    t.index ["user_id"], name: "index_ratings_on_user_id", using: :btree
  end

  create_table "studios", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "attendances", "exercise_classes"
  add_foreign_key "attendances", "users"
  add_foreign_key "exercise_classes", "categories"
  add_foreign_key "exercise_classes", "studios"
  add_foreign_key "ratings", "exercise_class_attributes"
  add_foreign_key "ratings", "exercise_classes"
  add_foreign_key "ratings", "users"
end
