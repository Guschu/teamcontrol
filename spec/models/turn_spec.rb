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

require 'rails_helper'

RSpec.describe Turn, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:team).class_name('Team') }
    it { is_expected.to belong_to(:driver).class_name('Driver') }
  end

  context '#for_event builds instance' do
    it 'w/ duration if race is started and mode is :both' do
      race = create :race, :started
      team = create :team, race:race
      att1 = create :attendance, team:team
      att2 = create :attendance, team:team

      Timecop.travel race.started_at.to_time
      att1.create_event # kommend
      Timecop.travel 10.minutes
      att2.create_event # kommend
      Timecop.travel 1.minutes
      att1.create_event # gehend
      Timecop.travel 20.minutes
      att2.create_event # gehend

      turns = Turn.for_team(team)
      expect(turns.count).to eq 2
      expect(turns.first.duration).to eq 11.minutes
      expect(turns.second.duration).to eq 21.minutes
    end

    it 'w/ duration for prebooking if race is started and mode is :both' do
      race = create :race, :started
      team = create :team, race:race
      att1 = create :attendance, team:team
      att2 = create :attendance, team:team

      Timecop.travel race.started_at.to_time - 5.minutes
      att1.create_event # kommend, Vorbuchung
      Timecop.travel 15.minutes # 10 Minuten nach Rennbeginn
      att2.create_event # kommend
      Timecop.travel 1.minutes
      att1.create_event # gehend
      Timecop.travel 20.minutes
      att2.create_event # gehend

      turns = Turn.for_team(team)
      expect(turns.count).to eq 2
      expect(turns.first.duration).to eq 11.minutes
      expect(turns.second.duration).to eq 21.minutes
    end

    it 'w/ duration if race is started and mode is :leaving' do
      race = create :race, :started, mode: :leaving
      team = create :team, race:race
      att1 = create :attendance, team:team
      att2 = create :attendance, team:team

      Timecop.travel race.started_at.to_time
      Timecop.travel 10.minutes
      att1.create_event # gehend
      Timecop.travel 20.minutes
      att2.create_event # gehend

      turns = Turn.for_team(team)
      expect(turns.count).to eq 2
      expect(turns.first.duration).to eq 10.minutes
      expect(turns.second.duration).to eq 20.minutes
    end
  end
end
