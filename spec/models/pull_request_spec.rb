require 'rails_helper'

RSpec.describe PullRequest, type: :model do
  it { is_expected.to validate_numericality_of :number }
  it { is_expected.to validate_presence_of :number }

  it { is_expected.to validate_presence_of :status }

  it { is_expected.to serialize(:pending_reviews) }
  it { is_expected.to serialize(:completed_reviews) }
end
