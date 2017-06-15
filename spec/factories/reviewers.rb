FactoryGirl.define do
  factory :reviewer do
    login "octocat"
    review_rule
    pull_request
  end
end
