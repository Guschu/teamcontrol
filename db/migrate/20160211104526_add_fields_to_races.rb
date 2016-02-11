class AddFieldsToRaces < ActiveRecord::Migration
  def change
    add_column :races, :scheduled, :date
    add_column :races, :started_at, :datetime
    add_column :races, :finished_at, :datetime
  end
end
