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
#  state          :integer
#  mode           :integer
#  scheduled      :date
#  started_at     :datetime
#  finished_at    :datetime
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
    it 'returns the active race' do
    end
  end
end
