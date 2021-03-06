# == Schema Information
#
# Table name: stations
#
#  id         :integer          not null, primary key
#  token      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_stations_on_token  (token)
#

FactoryGirl.define do
  factory :station do
    token '0123456789AB' # 12 chars hex
  end
end
