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
#  team_token        :string(255)
#  position          :integer
#  team_lead         :string(255)
#  attendances_count :integer
#
# Indexes
#
#  index_teams_on_race_id     (race_id)
#  index_teams_on_team_token  (team_token)
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

  describe '#batch_create_drivers' do
    it { is_expected.to respond_to :batch_create_drivers }

    it 'creates new drivers during save when set' do
      names = ['Max Muster', 'Bernd Bär', 'Thomas Test']
      team = create :team
      expect(team.drivers.count).to be 0

      team.batch_create_drivers = names.join("\n")
      expect(team.drivers.count).to be 0
      expect(team.save).to be true

      expect(team.drivers.count).to be 3
      expect(team.drivers.map(&:name)).to eq names
    end
  end

  describe '#has_unassigned_attendances?' do
    it 'returns true if any attendances have empty tag ids' do
      team = create :team
      create :attendance, team: team, tag_id: nil
      expect(team.has_unassigned_attendances?).to be true
    end

    it 'returns false if all attendances have tag ids set' do
      team = create :team
      create :attendance, team: team, tag_id: 'abc'
      expect(team.has_unassigned_attendances?).to be false
    end
  end
end
