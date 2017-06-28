class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  class << self
    def lookup(key)
      return nil unless exists?(key: key)
      raw = find_by(key: key).value
      Transit::Reader.new(:json, StringIO.new(raw)).read
    end

    def assign(key, value)
      io = StringIO.new("", "w+")
      Transit::Writer.new(:json, io).write(value)
      s = find_or_initialize_by(key: key)
      s.value = io.string
      s.save!
      s
    end
  end
end
