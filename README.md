# cody [![Build Status](https://travis-ci.org/aergonaut/cody.svg?branch=master)](https://travis-ci.org/aergonaut/cody)

**Cody** is your friendly neighborhood code review bot. Cody will monitor your
Pull Requests for comments and updates, and make sure that the people you've
called out for review have given their thumbs up on the code before it's merged.

## Features

- [x] Report code review progress with GitHub commit statuses
- [x] Determine list of reviewers from the Pull Request body
- [x] Reviewers give approval by leaving a comment
- [x] Review progress persists when the head commit of the branch changes
- [ ] Restart reviews on command
- [ ] Require a minimum number of reviews
- [ ] Require 1-n reviewers be from a given a list of reviewers
- [ ] Automatically choose reviewers based on PR characteristics

## License

MIT.
