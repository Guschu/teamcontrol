# == Schema Information
#
# Table name: attendances
#
#  id         :integer          not null, primary key
#  team_id    :integer
#  driver_id  :integer
#  tag_id     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_attendances_on_driver_id  (driver_id)
#  index_attendances_on_tag_id     (tag_id)
#  index_attendances_on_team_id    (team_id)
#
# Foreign Keys
#
#  fk_rails_14314e17d1  (team_id => teams.id)
#  fk_rails_4581e8741f  (driver_id => drivers.id)
#

require 'rails_helper'

RSpec.describe Attendance, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:team).class_name('Team') }
    it { is_expected.to belong_to(:driver).class_name('Driver') }
  end

  it 'calculates total time by driver' do
    race = create :race, :started
    team = create :team, race:race
    att1 = create :attendance, team:team
    att2 = create :attendance, team:team

    Timecop.travel race.started_at.to_time

    att1.create_event # kommend
    Timecop.travel 10.minutes

    att2.create_event # kommend
    Timecop.travel 1.minutes
    att1.create_event # gehend, 11 Minuten Fahrzeit
    Timecop.travel 20.minutes

    att1.create_event # kommend
    Timecop.travel 1.minutes
    att2.create_event # gehend, 21 Minuten Fahrzeit
    Timecop.travel 10.minutes

    att1.create_event # gehend, 11 Minuten Fahrzeit

    expect(att1.total_drivetime.to_i).to eq 22.minutes
    expect(att2.total_drivetime.to_i).to eq 22.minutes
  end
end
