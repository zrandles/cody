class ReviewRuleAlways < ReviewRule
  def matches?(*)
    "  - This rule is always triggered"
  end
end
