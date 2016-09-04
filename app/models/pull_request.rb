class PullRequest < ActiveRecord::Base
  validates :number, numericality: true, presence: true
  validates :status, presence: true
  validates :repository, presence: true

  serialize :pending_reviews, JSON
  serialize :completed_reviews, JSON

  after_initialize :default_pending_and_completed_reviews

  before_save :remove_duplicate_reviewers

  scope :pending_review, -> { where(status: "pending_review") }

  include GithubApi

  # List authors of commits in this pull request
  #
  # Returns the Array listing of all commit authors
  def commit_authors
    return [] unless repository

    github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
    commits = github.pull_request_commits(repository, number)

    commits.map do |commit|
      if author = commit[:author]
        author[:login]
      end
    end.compact
  end

  def assign_reviewers
    github_client.update_issue(
      self.repository,
      self.number,
      assignees: self.pending_reviews
    )
  end

  private

  def default_pending_and_completed_reviews
    if self.pending_reviews.nil?
      self.pending_reviews = []
    end

    if self.completed_reviews.nil?
      self.completed_reviews = []
    end
  end

  def remove_duplicate_reviewers
    reviewers = self.pending_reviews.uniq
    self.pending_reviews = reviewers
  end
end
