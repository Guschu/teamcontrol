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

FactoryGirl.define do
  factory :team do
    race
    name { Forgery::Name.company_name }
    team_token nil
    team_lead { Forgery::Name.full_name }
    logo do
      file = Dir['spec/fixtures/team_logos/*.png'].sample
      Rack::Test::UploadedFile.new(Rails.root.join(file), 'image/png')
    end
  end
end
