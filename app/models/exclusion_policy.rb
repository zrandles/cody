class ExclusionPolicy
  BLACKLIST = :blacklist
  WHITELIST = :whitelist

  def initialize(list, policy = BLACKLIST)
    @list = list
    @policy = policy
  end

  def permitted?(element)
    !((BLACKLIST == @policy) == @list.include?(element))
  end
end
