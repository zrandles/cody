namespace :graphql do
  desc "Export the GraphQL schema"
  task schema: :environment do
    File.write(
      Rails.root.join("schema.graphql"),
      GraphQL::Schema::Printer.print_schema(CodySchema)
    )
  end
end
