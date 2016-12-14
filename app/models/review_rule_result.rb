class ReviewRuleResult
  attr_reader :reviewer, :context

  def initialize(r = nil, c = nil)
    @reviewer = r
    @context = c
  end

  def success?
    !failure?
  end

  def failure?
    self.reviewer.nil?
  end
end
