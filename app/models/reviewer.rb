class Reviewer < ApplicationRecord
  belongs_to :review_rule, required: false
  belongs_to :pull_request

  STATUS_PENDING_APPROVAL = "pending_approval".freeze
  STATUS_APPROVED = "approved".freeze

  before_validation :default_status

  scope :from_rule, -> { where.not(review_rule_id: nil) }
  scope :pending_review, -> { where(status: STATUS_PENDING_APPROVAL) }
  scope :completed_review, -> { where(status: STATUS_APPROVED) }

  def addendum
    <<~EOF
      ### #{self.name_with_code}

      - [#{self.status_to_check}] @#{self.login}
      #{self.context}
    EOF
  end

  def status_to_check
    case status
    when STATUS_APPROVED
      "x"
    else
      " "
    end
  end

  def name_with_code
    if self.review_rule.short_code.present?
      "#{self.review_rule.name} (#{self.review_rule.short_code})"
    else
      self.review_rule.name
    end
  end

  def approve!
    self.status = STATUS_APPROVED
    save!
  end

  private

  def default_status
    self.status ||= STATUS_PENDING_APPROVAL
  end
end
