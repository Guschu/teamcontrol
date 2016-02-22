class AddCounterCacheToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :attendances_count, :integer
  end
end
