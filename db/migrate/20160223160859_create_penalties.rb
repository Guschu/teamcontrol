class CreatePenalties < ActiveRecord::Migration
  def change
    create_table :penalties do |t|
      t.references :team, index: true, foreign_key: true
      t.references :driver, index: true, foreign_key: true
      t.string :reason

      t.timestamps null: false
    end
  end
end
