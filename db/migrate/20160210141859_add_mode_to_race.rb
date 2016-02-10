class AddModeToRace < ActiveRecord::Migration
  def change
    add_column :races, :mode, :integer
    add_index :races, :mode
  end
end
