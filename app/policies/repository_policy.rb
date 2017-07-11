class RepositoryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      PullRequest
        .distinct
        .order("repository ASC")
        .pluck(:repository)
        .map do |nwo|

        owner, name = nwo.split("/", 2)
        Repository.new(owner: owner, name: name)
      end
    end
  end
end
