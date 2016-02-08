class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.references :team, index: true, foreign_key: true
      t.references :driver, index: true, foreign_key: true
      t.string :tag_id

      t.timestamps null: false
    end
    add_index :attendances, :tag_id
  end
end
