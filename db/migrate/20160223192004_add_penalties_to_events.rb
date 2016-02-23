class AddPenaltiesToEvents < ActiveRecord::Migration
  def change
    add_reference :events, :penalty, index: true, foreign_key: true
  end
end
