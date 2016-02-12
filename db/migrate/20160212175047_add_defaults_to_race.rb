class AddDefaultsToRace < ActiveRecord::Migration
  def change
    change_column :races, :state, :integer, default:0
    change_column :races, :mode, :integer, default:0
  end
end
