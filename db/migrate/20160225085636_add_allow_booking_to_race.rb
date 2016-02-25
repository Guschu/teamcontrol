class AddAllowBookingToRace < ActiveRecord::Migration
  def change
    add_column :races, :allow_booking, :boolean, default: false
  end
end
