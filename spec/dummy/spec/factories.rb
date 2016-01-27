FactoryGirl.define do
  factory :user do |f|
    f.email "foo@bar.com"
    f.password "ruby"
  end
end