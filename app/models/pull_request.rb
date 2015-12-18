class PullRequest < ActiveRecord::Base
  validates :number, numericality: true, presence: true
  validates :status, presence: true

  serialize :pending_reviews, JSON
  serialize :completed_reviews, JSON

  before_save :default_pending_and_completed_reviews

  scope :pending_review, -> { where(status: "pending_review") }

  private

  def default_pending_and_completed_reviews
    if self.pending_reviews.nil?
      self.pending_reviews = []
    end

    if self.completed_reviews.nil?
      self.completed_reviews = []
    end
  end
end
