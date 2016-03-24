class CreateOrUpdatePullRequest
  # Public: Creates or updates a Pull Request record in reponse to a webhook
  #
  # pull_request - A Hash-like object containing the PR data from the GitHub API
  # options - Hash of options
  #           :skip_review_rules - Boolean to apply review rules or skip
  def perform(pull_request, options = {})
    pr = PullRequest.find_or_initialize_by(number: pull_request["number"])

    pr_sha = pull_request["head"]["sha"]

    body = pull_request["body"] || ""
    check_box_pairs = body.scan(/[*-] +\[([ x])\] +@([A-Za-z0-9_-]+)/)

    # uniqueness by reviewer login
    check_box_pairs.uniq! { |pair| pair[1] }

    minimum_reviewers_required = Setting.lookup("minimum_reviewers_required")
    if minimum_reviewers_required.present? && check_box_pairs.count < minimum_reviewers_required
      github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
      github.create_status(
        pull_request["base"]["repo"]["full_name"],
        pr_sha,
        "failure",
        context: "code-review/cody",
        description: "APRICOT: Too few reviewers are listed",
        target_url: Setting.lookup("status_target_url")
      )

      return
    end

    pending_reviews = []
    completed_reviews = []

    check_box_pairs.each do |pair|
      if pair[0] == "x"
        completed_reviews << pair[1].strip
      else
        pending_reviews << pair[1].strip
      end
    end

    all_reviewers = pending_reviews + completed_reviews

    minimum_super_reviewers = Setting.lookup("minimum_super_reviewers")
    if minimum_super_reviewers.present?
      super_reviewers = Setting.lookup("super_reviewers")

      included_super_reviewers = all_reviewers.count { |r| super_reviewers.include?(r) }

      if included_super_reviewers < minimum_super_reviewers
        github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
        github.create_status(
          pull_request["base"]["repo"]["full_name"],
          pr_sha,
          "failure",
          context: "code-review/cody",
          description: "AVOCADO: PR does not meet super-review threshold",
          target_url: Setting.lookup("status_target_url")
        )

        return
      end
    end

    unless options[:skip_review_rules]
      ApplyReviewRules.new.perform(pull_request)
    end

    status = if pending_reviews.any?
      "pending_review"
    else
      "approved"
    end

    pr.status = status
    pr.pending_reviews = pending_reviews
    pr.completed_reviews = completed_reviews
    pr.save!

    commit_status = "pending"
    description = "Not all reviewers have approved. Comment \"LGTM\" to give approval."

    if pr.status == "approved"
      commit_status = "success"
      description = "Code review complete"
    end

    github = Octokit::Client.new(access_token: ENV["CODY_GITHUB_ACCESS_TOKEN"])
    github.create_status(
      pull_request["base"]["repo"]["full_name"],
      pr_sha,
      commit_status,
      context: "code-review/cody",
      description: description,
      target_url: Setting.lookup("status_target_url")
    )
  end
end
