class Setting < ActiveRecord::Base
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
      find_or_create_by!(key: key) do |s|
        s.value = io.string
      end
    end
  end
end
