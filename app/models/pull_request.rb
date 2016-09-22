class PullRequest < ActiveRecord::Base
  validates :number, numericality: true, presence: true
  validates :status, presence: true
  validates :repository, presence: true

  serialize :pending_reviews, JSON
  serialize :completed_reviews, JSON

  after_initialize :default_pending_and_completed_reviews

  before_save :remove_duplicate_reviewers

  scope :pending_review, -> { where(status: "pending_review") }

  COMMIT_STATUS_DESCRIPTIONS = {
    "pending" => "Not all reviewers have approved",
    "success" => "Code review complete",
    "failure" => "%s"
  }.freeze

  include GithubApi

  # List authors of commits in this pull request
  #
  # Returns the Array listing of all commit authors
  def commit_authors
    return [] unless repository

    commits = github_client.pull_request_commits(repository, number)

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

  def update_status(message = nil)
    github_client.create_status(
      self.repository,
      self.head_sha,
      commit_status,
      commit_status_details(message)
    )
  end

  def head_sha
    res = github_client.pull_request(self.repository, self.number)
    res.head.sha
  end

  private

  def commit_status
    case self.status
    when "pending_review"
      "pending"
    when "approved"
      "success"
    else
      "failure"
    end
  end

  def commit_status_details(message = nil)
    {
      context: "code-review/cody",
      description: COMMIT_STATUS_DESCRIPTIONS[commit_status] % message,
      target_url: Setting.lookup("status_target_url")
    }
  end

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
