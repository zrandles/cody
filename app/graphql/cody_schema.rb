CodySchema = GraphQL::Schema.define do
  query(Types::QueryType)

  id_from_object -> (object, type_definition, query_ctx) {
    if object.is_a?(ApplicationRecord)
      object.to_signed_global_id
    elsif object.respond_to?(:owner) && object.respond_to?(:name)
      Base64.urlsafe_encode64("#{object.owner}/#{object.name}")
    else
      raise "Unexpected object: #{object.inspect}"
    end
  }

  object_from_id -> (id, query_ctx) {
    if object = GlobalID::Locator.locate_signed(id)
      return object
    else
      decoded = Base64.urlsafe_decode64(id)
      if %r{[^/]+/[^/]+}.match?(decoded)
        owner, name = decoded.split("/", 2)
        return Repository.new(owner: owner, name: name)
      end
    end

    raise "Couldn't decode ID: #{id}"
  }

  resolve_type -> (obj, ctx) {
    case obj
    when PullRequest
      Types::PullRequestType
    when User
      Types::UserType
    when Repository
      Types::RepositoryType
    else
      raise "Unexpected object: #{obj}"
    end
  }
end
