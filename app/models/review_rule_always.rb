class ReviewRuleAlways < ReviewRule
  def matches?(*)
    true
  end
end
