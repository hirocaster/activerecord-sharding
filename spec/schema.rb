ActiveRecord::Schema.define(version: 0) do
  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end
end

ActiveRecord::Schema.define(version: 1) do
  create_table "items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.integer "count", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end
end
