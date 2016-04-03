# cody

[![Build Status](https://travis-ci.org/aergonaut/cody.svg?branch=master)](https://travis-ci.org/aergonaut/cody) [![Code Climate](https://codeclimate.com/github/aergonaut/cody/badges/gpa.svg)](https://codeclimate.com/github/aergonaut/cody)

**Cody** is your friendly neighborhood code review bot. Cody will monitor your
Pull Requests for comments and updates, and make sure that the people you've
called out for review have given their thumbs up on the code before it's merged.

## Features

- [x] Report code review progress with GitHub commit statuses
- [x] Determine list of reviewers from the Pull Request body
- [x] Reviewers give approval by leaving a comment
- [x] Review progress persists when the head commit of the branch changes
- [x] Require a minimum number of reviews
- [x] Rebuild reviews list from PR description on command
- [x] Require 1-n reviewers be from a given a list of reviewers ("super reviewers")
- [x] Automatically choose reviewers based on PR characteristics

### Anti-features (Not Doing)

* :x: Web interface of any kind
* :x: "Approval groups" (i.e. one of Jane _or_ Mary could :+1:).

## Usage

### Requesting review

To request a review, simply open a new PR and include your desired reviewers in
the form of a [GitHub task list][] in the PR description:

![example-pr](http://cl.ly/e9tF/example-pr.png)

[GitHub task list]: https://github.com/blog/1375%0A-task-lists-in-gfm-issues-pulls-comments

Checking off a box will make sure that reviewer won't need to approve again if
the reviews list is rebuilt later.

### Approving a PR

To approve a PR, you must be a reviewer for that PR and you must leave a comment
with one of the following affirmative phrases on the PR:

* LGTM
* Looks good
* Looks good to me
* :+1:
* :ok:
* :shipit:
* :rocket:
* :100:

You comment should be on its own line with no other text on the same line. The
phrases are case-insensitive. You may include other text in your comment, but
the affirmative phrase should be on its own line.

#### Retracting approval

If you previously approved a PR but want to retract your approval, you can do
the following:

1. Uncheck your check box in the task list in the PR description
2. Issue the `!rebuild-reviews` command

Cody will rebuild the reviews list from the task list, and count you as
unapproved because your check box is not checked.

### Review Rules

Review rules allow Cody to automatically assign reviewers to incoming PRs based
on criteria you define. This makes it easy for you and your contributors to
make sure that a PR is reviewed by the people who know that code best.

Cody supports the following types of rules:

* Matching the paths of changed files against a regular expression
* Rules that always apply

When a rule matches, you can configure Cody either to assign a specific reviewer
or to choose a reviewer from a given GitHub Team. If you use a Team, Cody will
randomly pick a reviewer from the Team members.

Reviewers added by a review rule may include extra context from the review rule
to clarify what in the PR specifically needs to be reviewed. This may be a list
of file names, excerpts from the changeset, etc.

### Using "super reviewers"

**DEPRECATION NOTICE:** Super reviewers are being deprecated and will be
removed in a future version of Cody. Use ReviewRuleAlways to automatically
assign a reviewer from a GitHub Team on all incoming PRs instead.

Cody has the concept of "super reviewers". These are a list of reviewers that
you want to ensure sign off on every PR that gets merged.

Cody allows you to configure your list of super reviewers, and also configure
how many super reviewer approvals you want to require for each PR.

PRs that do not include enough super reviewers in the review list will be marked
with the failed status until the reviews are rebuilt and enough super reviewers
are added.

### Recalculating reviews

Cody will keep the list of pending reviews up-to-date as your reviewers approve.

However, if you decide to change the review list, you will need to inform Cody
that new reviewers were chosen and the list of reviews needs to be rebuilt. This
is necessary because the GitHub API does not have a way of detecting when the
body of PR is changed.

To recalculate the review list, leave a comment with the following text:

```
!rebuild-reviews
```

This will instruct the bot to rebuild the review list based on the task list in
the PR description. Reviewers that have already checked their box will be
pre-approved in the new list of reviews.

### Controlling what Pull Requests require reviews

#### Using a branch filter

Cody can filter incoming Pull Requests via a branch filter and a filter policy.

The filter is simply a list of branch names. The policy controls whether the
filter behaves like a whitelist (only require reviews on Pull Requests that
target the branches in this list), or blacklist (require reviews on all Pull
Requests except those that target branches in this list).

## Setup

To use Cody in your own team, you should deploy your own instance of the app to
some server you control. My team uses Cody with Heroku.

### Heroku Deployment

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

If you use Heroku, you can use the above button to quickly deploy the app to
your Heroku account.

See the **Configuration** section below for information on how to setup Cody.

### DIY

* Ruby 2.2.4
* Postgres
* Redis

### Configuration

At the moment configuration is handled through the Rails console using the
`Setting` model. I may change this in the future if configuration becomes more
complex.

Consult the table below for a list of relevant settings and their function:

Key | Description | Example
----|-------------|--------
`minimum_reviewers_required` | *Fixnum*. The minimum number of reviewers required on every Pull Request. | `Setting.assign "minimum_reviewers_required", 2`
`super_reviewers` | **DEPRECATED** *Array*. The list of GitHub users that are super reviewers. | `Setting.assign "super_reviewers", ["aergonaut", "BrentW"]`
`minimum_super_reviewers` | **DEPRECATED** *Fixnum*. The minimum number of super reviewers required on every Pull Request. | `Setting.assign "minimum_super_reviewers", 1`
`branch_filter` | *Array*. A list of branches to filter incoming Pull Requests by merge base. | `Setting.assign "branch_filter", ["experimental"]`
`branch_filter_policy` | *Symbol*. Either `:blacklist` or `:whitelist`. Controls the behavior of the branch filter. | `Setting.assign "branch_filter_policy", :blacklist`
`status_target_url` | *String*. The URL to link to in the GitHub commit status. | `Setting.assign "status_target_url", "https://yourteam.com/wiki/code-review-policies"`

To set these configuration values, use the Rails console.

### Webhooks

Cody works by receiving GitHub webhooks triggered by events in your repository.

Configure the following webhooks in the repositories you want to use with Cody:

#### Pull Request

![Pull Request webhook configuration](http://cl.ly/ekoQ/pull_request_webhook.png)

#### Issue comment

![Issue comment webhook configuration](http://cl.ly/em7e/issue_comment_webhook.png)

## License

MIT.
