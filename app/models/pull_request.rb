class PullRequest < ActiveRecord::Base
  validates :number, numericality: true, presence: true
  validates :status, presence: true
end
