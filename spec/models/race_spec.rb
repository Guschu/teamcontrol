# == Schema Information
#
# Table name: races
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  duration       :integer
#  max_drive      :integer
#  max_turn       :integer
#  break_time     :integer
#  waiting_period :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  slug           :string(255)
#  state          :integer          default(0)
#  mode           :integer          default(0)
#  scheduled      :date
#  started_at     :datetime
#  finished_at    :datetime
#  min_turn       :integer
#
# Indexes
#
#  index_races_on_mode  (mode)
#  index_races_on_slug  (slug)
#

require 'rails_helper'

RSpec.describe Race, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:teams).class_name('Team') }
  end

  it { should define_enum_for :state }
  it { should define_enum_for :mode }

  context 'allow booking' do
    subject{ create :race }

    it 'to be false in default' do
      expect(subject).to_not be_allow_booking
    end

    it 'after race started' do
      subject.start!
      expect(subject).to be_allow_booking
    end
  end

  it 'has events' do
    race = create :race, :started
    team = create :team, race: race
    att = create :attendance, team: team
    evt = att.create_event

    expect(team.events).to be_a ActiveRecord::Relation
    expect(team.events.to_a).to eq [evt]
  end

  it 'has a started_at timestamp after start' do
    race = create :race
    expect(race.started_at).to be_nil
    race.start!
    expect(race.started_at).not_to be_nil
  end

  it 'has a finished_at timestamp after finish' do
    race = create :race, :started
    expect(race.finished_at).to be_nil
    race.finish!
    expect(race.finished_at).not_to be_nil
  end

  describe '#current_race' do
    it 'returns the started race' do
      r1 = create :race, :finished, scheduled: 14.days.ago
      r2 = create :race, :started
      r3 = create :race, scheduled: 14.days.from_now # planned by default

      expect(Race.current_race).to eq r2
    end

    it 'returns the next scheduled race' do
      r1 = create :race, :finished, scheduled: 14.days.ago
      r2 = create :race, scheduled: 7.days.from_now
      r3 = create :race, scheduled: 14.days.from_now
      expect(Race.current_race).to eq r2
    end

    it 'returns nil of no started nor planned race' do
      r1 = create :race, :finished, scheduled: 14.days.ago
      r2 = create :race, :finished, scheduled: 7.days.ago
      expect(Race.current_race).to be_nil
    end
  end

  describe '#current_race?' do
    it 'returns true if there is a current race' do
    end
  end
end
