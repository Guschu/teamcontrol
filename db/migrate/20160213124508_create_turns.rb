class CreateTurns < ActiveRecord::Migration
  def change
    create_table :turns do |t|
      t.references :team, index: true, foreign_key: true
      t.references :driver, index: true, foreign_key: true
      t.integer :duration

      t.timestamps null: false
    end
  end
end
