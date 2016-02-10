class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.references :team, index: true, foreign_key: true
      t.references :driver, index: true, foreign_key: true
      t.integer :mode

      t.timestamps null: false
    end
  end
end
