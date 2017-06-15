# Contributing

## Local environment setup

### Prerequisites

You will need:

* Ruby 2.2.3
* Postgres
* Redis

If you're on Mac OS X, I suggest using [Postgres.app][] to install Postgres for
you. If you want a GUI client for Postgres, I suggest [Postico][].

[Postgres.app]: http://postgresapp.com/
[Postico]: https://eggerapps.at/postico/

### Environment file

A `.env.sample` file is included in the repo. You should copy this to `.env`
and replace the values there with your own for local development.

The `.env` file is used in test mode through Dotenv and in development mode
through Foreman.

## Developing

1. Fork the repo
2. Clone your fork
3. Create a branch
4. Commit some changes
5. Open a Pull Request

Since nearly all of Cody's interaction is through GitHub webhooks, running the
app in development mode is actually not that useful.

When developing a new feature, you should figure out what webhook payload you
want to respond to first. Then take the sample payload from the GitHub
documentation and begin writing tests that stub out the incoming requests with
the example payload.

### Rubocop

Code style is enforced in PRs with Rubocop. You can check out the repo's config
in the `.rubocop.yml` file.

When developing locally, please run Rubocop on your code before submitting PRs.
It's also a good idea to set up integration with your editor so you have
continuous feedback.

PRs with style violations will not be accepted.

## Resources

* [GitHub API documentation](https://developer.github.com/v3/)
* [Octokit.rb documentation](http://octokit.github.io/octokit.rb/)
