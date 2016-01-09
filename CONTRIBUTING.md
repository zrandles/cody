# Contributing

## Local environment setup

### Prerequisites

You will need:

* Ruby 2.2.3
* Postgres

### Environment file

A `.env.sample` file is included in the repo. You should copy this to `.env`
and replace the values there with your own for local development.

The `.env` file is used in test mode through Dotenv and in development mode
through Foreman.

## Development

Since nearly all of Cody's interaction is through GitHub webhooks, running the
app in development mode is actually not that useful.

When developing a new feature, you should figure out what webhook payload you
want to respond to first. Then take the sample payload from the GitHub
documentation and begin writing tests that stub out the incoming requests with
the example payload.
