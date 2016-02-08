FactoryGirl.define do
  factory :driver do
    name { Forgery::Name.full_name }
  end
end
