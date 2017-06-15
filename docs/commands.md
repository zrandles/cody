# Commands

All commands begin with `cody`.

To issue a command, leave a comment on the Pull Request you are interested in.

## Approve

**Usage:** `cody approve`

Give approval as a reviewer for a PR.

You normally won't use this command but will instead use one of the various
affirmative phrases that Cody recognizes. However if you wish to use this
command to approve, you are welcome to do so.

## Rebuild

**Usage:** `cody rebuild`

Rebuild the review list for a PR.

This scans the PR for changes to the peer review list and synchronizes it with
Cody's internal review progress.

All Review Rules are checked again for matches and new reviewers from the Rules
are potentially added.

## Replace

**Usage:** `cody replace DIRECTIVES...`

Replace one or more Generated Reviewers according to the given `DIRECTIVES`.

A `DIRECTIVE` has the following format:

```
DIRECTIVE := SHORT_CODE '=' GITHUB_LOGIN

SHORT_CODE := [A-Za-z0-9_-]+

GITHUB_LOGIN := [A-Za-z0-9_-]+
```

`SHORT_CODE`s are printed in parentheses next to the Review Rule's name in the
Generated Reviewers section.

The `GITHUB_LOGIN` must identify a GitHub user who

1.  Has access to the repository, and
2.  Is a possible reviewer for the Review Rule identified by the `SHORT_CODE`
