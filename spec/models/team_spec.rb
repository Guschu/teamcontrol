# == Schema Information
#
# Table name: teams
#
#  id                :integer          not null, primary key
#  race_id           :integer
#  name              :string(255)
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :integer
#  logo_updated_at   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_teams_on_race_id  (race_id)
#
# Foreign Keys
#
#  fk_rails_4a0c7e1679  (race_id => races.id)
#

require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:race).class_name('Race') }
    it { is_expected.to have_many(:attendances).class_name('Attendance') }
    it { is_expected.to have_many(:drivers).class_name('Driver') }
  end

  describe '#current_driver' do
    it 'returns nil if race mode is :leaving' do
      @race = create :race, :started, mode: :leaving
      @team = create :team, race: @race
      @driver1 = create :driver
      @driver2 = create :driver
      @att1 = create :attendance, :with_tag, team: @team, driver: @driver1
      @att2 = create :attendance, :with_tag, team: @team, driver: @driver2

      @att1.create_event
      expect(@team.current_driver).to be_nil
    end

    it 'returns driver if race mode is :both' do
      @race = create :race, :started, mode: :both
      @team = create :team, race: @race
      @driver1 = create :driver
      @driver2 = create :driver
      @att1 = create :attendance, :with_tag, team: @team, driver: @driver1
      @att2 = create :attendance, :with_tag, team: @team, driver: @driver2

      Timecop.travel @race.started_at.to_time
      @att1.create_event # Fahrer 1 beginnt
      expect(@team.current_driver).to eq @driver1

      Timecop.travel 30 * 60
      @att2.create_event # Fahrer 2 kommt
      expect(@team.current_driver).to eq @driver2

      Timecop.travel 2 * 60
      @att1.create_event # Fahrer 1 verlässt die Bahn

      expect(@team.current_driver).to eq @driver2
    end
  end

  describe '#last_driver' do
    it 'returns last leaving driver' do
      @race = create :race, :started, mode: :leaving
      @team = create :team, race: @race
      @driver1 = create :driver
      @driver2 = create :driver
      @att1 = create :attendance, :with_tag, team: @team, driver: @driver1
      @att2 = create :attendance, :with_tag, team: @team, driver: @driver2

      Timecop.travel @race.started_at.to_time
      @att1.create_event

      Timecop.travel 30 * 60
      @att2.create_event

      expect(@team.last_driver).to eq @driver2
    end
  end
end
