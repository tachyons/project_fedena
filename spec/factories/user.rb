FactoryGirl.define do
  factory :user do
    first_name { "John" }
    last_name  { "Doe" }
    username {"fedena"}
    role {"admin" }
    password "admin123"
  end
end
