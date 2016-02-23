# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  team_id    :integer
#  driver_id  :integer
#  mode       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  penalty_id :integer
#
# Indexes
#
#  index_events_on_driver_id   (driver_id)
#  index_events_on_penalty_id  (penalty_id)
#  index_events_on_team_id     (team_id)
#
# Foreign Keys
#
#  fk_rails_74371719e9  (driver_id => drivers.id)
#  fk_rails_f5fcdb65ec  (penalty_id => penalties.id)
#  fk_rails_f62361cf64  (team_id => teams.id)
#

class Event < ActiveRecord::Base
  belongs_to :team
  belongs_to :driver
  belongs_to :penalty

  enum mode: { arriving: 1, leaving: 2 }

  validates :team_id, :driver_id, :mode, presence: true
end
