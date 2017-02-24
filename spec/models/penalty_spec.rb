# == Schema Information
#
# Table name: penalties
#
#  id         :integer          not null, primary key
#  team_id    :integer
#  driver_id  :integer
#  reason     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_penalties_on_driver_id  (driver_id)
#  index_penalties_on_team_id    (team_id)
#
# Foreign Keys
#
#  fk_rails_2f83aa445f  (team_id => teams.id)
#  fk_rails_4bd86e846b  (driver_id => drivers.id)
#

require 'rails_helper'

RSpec.describe Penalty, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:team).class_name('Team') }
    it { is_expected.to belong_to(:driver).class_name('Driver') }
  end
end
