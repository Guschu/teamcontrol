FactoryGirl.define do
  factory :turn do
    team
    driver
    duration { rand(1200) }
  end
end
