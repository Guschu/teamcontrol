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
#
# Indexes
#
#  index_events_on_driver_id  (driver_id)
#  index_events_on_team_id    (team_id)
#
# Foreign Keys
#
#  fk_rails_74371719e9  (driver_id => drivers.id)
#  fk_rails_f62361cf64  (team_id => teams.id)
#

require 'rails_helper'

RSpec.describe Event, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
