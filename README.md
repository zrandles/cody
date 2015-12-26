# cody [![Build Status](https://travis-ci.org/aergonaut/cody.svg?branch=master)](https://travis-ci.org/aergonaut/cody)

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
- [ ] Require 1-n reviewers be from a given a list of reviewers
- [ ] Automatically choose reviewers based on PR characteristics

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

## License

MIT.
