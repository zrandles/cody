FactoryGirl.define do
  factory :pull_request do
    status "pending_review"
    sequence(:number)
    repository "aergonaut/testrepo"
  end
end
