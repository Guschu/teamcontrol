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
  describe 'associations' do
    it { is_expected.to belong_to(:team).class_name('Team') }
    it { is_expected.to belong_to(:driver).class_name('Driver') }
  end

  it { should define_enum_for :mode }

  describe '#create before prebooking' do
    let(:race) { create :race, prebooking_open:false }
    let(:team) { create :team, race:race }
    let(:attendance) { create :attendance, team:team }

    it 'is not allowed' do
      expect(race.aasm.current_state).to be :planned

      evt = Event.create team_id:attendance.team_id, driver_id:attendance.driver_id
      expect(evt).not_to be_persisted
      expect(evt.errors).not_to be_empty
    end
  end

  describe '#create while prebooking' do
    let(:race) { create :race, prebooking_open:true }
    let(:team) { create :team, race:race }
    let(:team2) { create :team, race:race }
    let(:attendance) { create :attendance, team:team }
    let(:attendance2) { create :attendance, team:team }
    let(:attendance3) { create :attendance, team:team2 }

    it 'is allowed once per driver' do
      expect(race.aasm.current_state).to be :planned

      # Erster Fahrer
      evt = Event.create team_id:attendance.team_id, driver_id:attendance.driver_id
      expect(evt.errors).to be_empty
      expect(evt).to be_persisted

      # Erster Fahrer nochmal
      Timecop.travel 5.seconds
      evt = Event.create team_id:attendance.team_id, driver_id:attendance.driver_id
      expect(evt.errors).not_to be_empty
      expect(evt).to be_new_record
    end

    it 'is allowed once per team' do
      expect(race.aasm.current_state).to be :planned

      # erster Fahrer in Team 1
      evt = Event.create team_id:attendance.team_id, driver_id:attendance.driver_id
      expect(evt.errors).to be_empty
      expect(evt).to be_persisted

      # zweiter Fahrer des gleichen Teams
      Timecop.travel 5.seconds
      evt = Event.create team_id:attendance2.team_id, driver_id:attendance2.driver_id
      expect(evt.errors).not_to be_empty
      expect(evt).to be_new_record

      # Fahrer einen anderen Teams
      Timecop.travel 5.seconds
      evt = Event.create team_id:attendance3.team_id, driver_id:attendance3.driver_id
      expect(evt.errors).to be_empty
      expect(evt).to be_persisted
    end
  end

  describe '#create while race active' do
    let(:race) { create :race, :started }
    let(:team) { create :team, race:race }
    let(:team2) { create :team, race:race }
    let(:attendance) { create :attendance, team:team }
    let(:attendance2) { create :attendance, team:team }
    let(:attendance3) { create :attendance, team:team2 }

    it ''
  end
end
