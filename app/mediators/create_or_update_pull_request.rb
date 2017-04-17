class CreateOrUpdatePullRequest
  # Public: Creates or updates a Pull Request record in reponse to a webhook
  #
  # pull_request - A Hash-like object containing the PR data from the GitHub API
  # options - Hash of options
  #           :skip_review_rules - Boolean to apply review rules or skip
  def perform(pull_request, options = {})
    pr = PullRequest.find_or_initialize_by(
      number: pull_request["number"],
      repository: pull_request['base']['repo']['full_name']
    )

    github = Octokit::Client.new(access_token: Rails.application.secrets.github_access_token)

    pr_sha = pull_request["head"]["sha"]

    body = pull_request["body"] || ""
    check_box_pairs = body.scan(/[*-] +\[([ x])\] +@([A-Za-z0-9_-]+)/)

    # uniqueness by reviewer login
    check_box_pairs.uniq! { |pair| pair[1] }

    minimum_reviewers_required = Setting.lookup("minimum_reviewers_required")
    if minimum_reviewers_required.present? && check_box_pairs.count < minimum_reviewers_required
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

    reviewers_without_access = pending_reviews.select do |reviewer|
      !github.collaborator?(pr.repository, reviewer)
    end

    unless reviewers_without_access.empty?
      verb_phrase = if reviewers_without_access.count > 1
        "are not collaborators"
      else
        "is not a collaborator"
      end

      github.create_status(
        pull_request["base"]["repo"]["full_name"],
        pr_sha,
        "failure",
        context: "code-review/cody",
        description: "PLUM: #{reviewers_without_access.join(", ")} #{verb_phrase} on this repository",
        target_url: Setting.lookup("status_target_url")
      )

      return
    end

    pr.status = "pending_review"
    pr.pending_reviews = pending_reviews
    pr.completed_reviews = completed_reviews
    pr.save!

    unless options[:skip_review_rules]
      ApplyReviewRules.new.perform(pull_request)
    end

    pr.reload
    pending_reviews = pr.pending_reviews

    status = if pending_reviews.any?
      "pending_review"
    else
      "approved"
    end

    pr.status = status
    pr.save!

    pr.update_status
    pr.assign_reviewers
  end
end
