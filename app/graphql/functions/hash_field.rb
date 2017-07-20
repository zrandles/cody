module Functions
  class HashField < GraphQL::Function
    attr_reader :type
    def initialize(field, type)
      @field = field
      @type = type
    end

    def call(obj, _args, _ctx)
      obj[@field]
    end
  end
end
