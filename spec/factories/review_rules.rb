FactoryGirl.define do
  factory :review_rule do
    sequence(:name) { |x| "Review Rule #{x}" }
    reviewer "octocat"
    repository "aergonaut/testrepo"

    factory :review_rule_file_match, class: ReviewRuleFileMatch
    factory :review_rule_diff_match, class: ReviewRuleDiffMatch
    factory :review_rule_always, class: ReviewRuleAlways
  end
end
