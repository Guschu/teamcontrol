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

RSpec::Matchers.define :be_successfully_created do
  match do |actual|
    actual.persisted? && actual.errors.empty?
  end
end

RSpec::Matchers.define :be_created_with_errors do
  match do |actual|
    actual.new_record? && actual.errors.present?
  end
end

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
      expect(evt).to be_successfully_created

      # Erster Fahrer nochmal
      Timecop.travel 5.seconds
      evt = Event.create team_id:attendance.team_id, driver_id:attendance.driver_id
      expect(evt).to be_created_with_errors
    end

    it 'is allowed once per team' do
      expect(race.aasm.current_state).to be :planned

      # erster Fahrer in Team 1
      evt = Event.create team_id:attendance.team_id, driver_id:attendance.driver_id
      expect(evt).to be_successfully_created

      # zweiter Fahrer des gleichen Teams
      Timecop.travel 5.seconds
      evt = Event.create team_id:attendance2.team_id, driver_id:attendance2.driver_id
      expect(evt).to be_created_with_errors

      # Fahrer einen anderen Teams
      Timecop.travel 5.seconds
      evt = Event.create team_id:attendance3.team_id, driver_id:attendance3.driver_id
      expect(evt).to be_successfully_created
    end
  end

  describe '#create while race active' do
    let(:race) { create :race, :started }
    let(:team) { create :team, race:race }
    let(:attendance) { create :attendance, team:team }
    let(:attendance2) { create :attendance, team:team }
    let(:attendance3) { create :attendance, team:team }

    it '1st driver arrives at first event' do
      evt = Event.create team_id:attendance.team_id, driver_id:attendance.driver_id
      expect(evt).to be_successfully_created
      expect(evt.arriving?).to be true
    end

    it '2nd driver arrives at second event' do
      Event.create team_id:attendance.team_id, driver_id:attendance.driver_id

      Timecop.travel 5.seconds
      evt = Event.create team_id:attendance2.team_id, driver_id:attendance2.driver_id
      expect(evt).to be_successfully_created
      expect(evt.arriving?).to be true
    end

    it '1st driver leaves at third event' do
      Event.create team_id:attendance.team_id, driver_id:attendance.driver_id

      Timecop.travel 5.seconds
      Event.create team_id:attendance2.team_id, driver_id:attendance2.driver_id

      Timecop.travel 5.seconds
      evt = Event.create team_id:attendance.team_id, driver_id:attendance.driver_id
      expect(evt).to be_successfully_created
      expect(evt.leaving?).to be true
    end

    it '2nd driver leaves at fourth event' do
      Event.create team_id:attendance.team_id, driver_id:attendance.driver_id

      Timecop.travel 5.seconds
      Event.create team_id:attendance2.team_id, driver_id:attendance2.driver_id

      Timecop.travel 5.seconds
      Event.create team_id:attendance.team_id, driver_id:attendance.driver_id

      Timecop.travel 5.seconds
      evt = Event.create team_id:attendance2.team_id, driver_id:attendance2.driver_id
      expect(evt).to be_successfully_created
      expect(evt.leaving?).to be true
    end

    it '3rd driver arrives at fourth event' do
      Event.create team_id:attendance.team_id, driver_id:attendance.driver_id

      Timecop.travel 5.seconds
      Event.create team_id:attendance2.team_id, driver_id:attendance2.driver_id

      Timecop.travel 5.seconds
      Event.create team_id:attendance.team_id, driver_id:attendance.driver_id

      Timecop.travel 5.seconds
      evt = Event.create team_id:attendance3.team_id, driver_id:attendance3.driver_id
      expect(evt).to be_successfully_created
      expect(evt.arriving?).to be true
    end

    it '2nd driver leaves at fifth event' do
      Event.create team_id:attendance.team_id, driver_id:attendance.driver_id

      Timecop.travel 5.seconds
      Event.create team_id:attendance2.team_id, driver_id:attendance2.driver_id

      Timecop.travel 5.seconds
      Event.create team_id:attendance.team_id, driver_id:attendance.driver_id

      Timecop.travel 5.seconds
      evt = Event.create team_id:attendance3.team_id, driver_id:attendance3.driver_id

      Timecop.travel 5.seconds
      evt = Event.create team_id:attendance2.team_id, driver_id:attendance2.driver_id
      expect(evt).to be_successfully_created
      expect(evt.leaving?).to be true
    end

    it '1st leaves at second event' do
      Event.create team_id:attendance.team_id, driver_id:attendance.driver_id

      Timecop.travel 5.seconds
      evt = Event.create team_id:attendance.team_id, driver_id:attendance.driver_id
      expect(evt).to be_successfully_created
      expect(evt.leaving?).to be true
    end

    context 'errors' do
    end
  end

  describe '#create while race finished' do
    let(:race) { create :race, :finished }
    let(:team) { create :team, race:race }
    let(:attendance) { create :attendance, team:team }

    it 'does not allow event creation' do
      evt = Event.create team_id:attendance.team_id, driver_id:attendance.driver_id
      expect(evt).to be_created_with_errors
    end
  end
end
