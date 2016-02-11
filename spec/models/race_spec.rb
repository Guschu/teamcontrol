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

  end
end
