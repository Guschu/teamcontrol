class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.string :token

      t.timestamps null: false
    end
    add_index :stations, :token
  end
end
