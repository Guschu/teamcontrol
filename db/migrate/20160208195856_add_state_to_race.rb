class AddStateToRace < ActiveRecord::Migration
  def change
    add_column :races, :state, :integer
  end
end
