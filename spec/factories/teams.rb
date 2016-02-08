FactoryGirl.define do
  factory :team do
    race
    name  { Forgery::Name.company_name }
    logo ""
  end
end
