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

  describe '#is_unassigned?' do
    it 'returns true if tag_id is unset' do
      expect(Attendance.new(tag_id: 'ABC').is_unassigned?).to be false
      expect(Attendance.new(tag_id: '').is_unassigned?).to be true
      expect(Attendance.new(tag_id: nil).is_unassigned?).to be true
    end
  end

  it 'creates events and turns' do
    race = create :race, :started
    team = create :team, race: race
    att1 = create :attendance, team: team
    att2 = create :attendance, team: team

    Timecop.travel race.started_at.to_time

    att1.create_event # kommend
    expect(team.events.arriving.count).to eq 1

    s = team.to_stats
    expect(s.turns.size).to eq 0
    expect(s.current_driver_id).to eq att1.driver_id
    expect(s.last_driver_id).to be_nil
    Timecop.travel 10.minutes

    att2.create_event # kommend
    expect(team.events.arriving.count).to eq 2

    s = team.to_stats
    expect(s.turns.size).to eq 0
    expect(s.current_driver_id).to eq att2.driver_id
    expect(s.last_driver_id).to eq att1.driver_id
    Timecop.travel 1.minutes

    att1.create_event # gehend, 11 Minuten Fahrzeit
    expect(team.events.arriving.count).to eq 2
    expect(team.events.leaving.count).to eq 1

    s = team.to_stats
    expect(s.turns.size).to eq 1
    expect(s.current_driver_id).to eq att2.driver_id
    expect(s.last_driver_id).to eq att1.driver_id
    Timecop.travel 20.minutes

    s = team.to_stats
    expect(s.last_break_time).to eq 20.minutes # att1 fährt nicht seit 20 Minuten

    att2.create_event # gehend, 21 Minuten Fahrzeit
    Timecop.travel 10.minutes
    expect(team.events.arriving.count).to eq 2
    expect(team.events.leaving.count).to eq 2

    s = team.to_stats
    expect(s.turns.size).to eq 2
    expect(s.current_driver_id).to be_nil
    expect(s.last_driver_id).to eq att2.driver_id
  end
end
