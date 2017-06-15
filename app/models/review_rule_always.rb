class ReviewRuleAlways < ReviewRule
  def matches?(*)
    self.match_context = "  - This rule is always triggered"
  end
end
