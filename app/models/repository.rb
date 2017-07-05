class Repository
  attr_reader :owner, :name

  def initialize(owner:, name:)
    @owner = owner
    @name = name
  end

  def pull_requests
    binding.pry
    PullRequest.where(repository: "#{owner}/#{name}")
  end
end
