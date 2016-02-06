class CreateRaces < ActiveRecord::Migration
  def change
    create_table :races do |t|
      t.string :name
      t.integer :duration
      t.integer :max_drive
      t.integer :max_turn
      t.integer :break_time
      t.integer :waiting_period

      t.timestamps null: false
    end
  end
end
