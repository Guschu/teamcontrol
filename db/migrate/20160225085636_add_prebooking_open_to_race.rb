class AddPrebookingOpenToRace < ActiveRecord::Migration
  def change
    add_column :races, :prebooking_open, :boolean, default: false
  end
end
