class User < ApplicationRecord
  validates :login, presence: true
  validates :uid, presence: true
end
