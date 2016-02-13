# == Schema Information
#
# Table name: turns
#
#  id         :integer          not null, primary key
#  team_id    :integer
#  driver_id  :integer
#  duration   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_turns_on_driver_id  (driver_id)
#  index_turns_on_team_id    (team_id)
#
# Foreign Keys
#
#  fk_rails_a98f3bc47c  (driver_id => drivers.id)
#  fk_rails_d3380a493d  (team_id => teams.id)
#

class Turn < ActiveRecord::Base
  belongs_to :team
  belongs_to :driver
end
