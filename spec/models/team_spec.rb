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
end
