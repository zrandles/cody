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
- [ ] Automatically choose reviewers based on PR characteristics

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

### Recalculating reviews

If the list of reviewers changes, either the PR author or any of the previously
listed reviewers can recalculate the review list.

To recalculate the review list, leave a comment with the following text:

```
!rebuild-reviews
```

This will instruct the bot to rebuild the review list based on the task list in
the PR description. Reviewers that have already checked their box will be pre-approved
in the new list of reviews.

### Retracting approval

If you previously approved a PR but want to retract your approval, you can do
the following:

1. Uncheck your check box in the task list in the PR description
2. Issue the `!rebuild-reviews` command

Cody will rebuild the reviews list from the task list, and count you as
unapproved because your check box is not checked.

### Using "super reviewers"

Cody has the concept of "super reviewers". These are a list of reviewers that
you want to ensure sign off on every PR that gets merged.

Cody allows you to configure your list of super reviewers, and also configure
how many super reviewer approvals you want to require for each PR.

PRs that do not include enough super reviewers in the review list will be marked
with the failed status until the reviews are rebuilt and enough super reviewers
are added.

## License

MIT.
