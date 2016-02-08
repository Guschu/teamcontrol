# == Schema Information
#
# Table name: drivers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :driver do
    name { Forgery::Name.full_name }
  end
end
