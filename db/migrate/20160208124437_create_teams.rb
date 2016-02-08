class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.references :race, index: true, foreign_key: true
      t.string :name
      t.attachment :logo

      t.timestamps null: false
    end
  end
end
