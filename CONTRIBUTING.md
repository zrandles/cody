# Contributing to Cody

Thanks for wanting to contribute to Cody! There are many ways to contribute, and
we appreciate all of them!

* [Bug Reports](#bug-reports)
* [Feature Requests](#feature-requests)
* [Contributing Code](#contributing-code)
  * [Dependency Setup](#dependency-setup)
  * [Environment](#environment)
  * [Setup Personal Access Token](#setup-personal-access-token)
  * [Setup GitHub App](#setup-github-app)
  * [Running the App](#running-the-app)
  * [Submitting Pull Requests](#submitting-pull-requests)

## Bug Reports

First have a look at our [existing issues](https://github.com/aergonaut/cody/issues).
Try to find an issue, open or closed, that describes your problem, or a very
similar one. If you can't find something related, then please open an issue.

Please try to include as much information as possible in your bug report.

Bugs are marked with the label `T-bug`.

## Feature Requests

We welcome feature requests to fill gaps in workflows Cody currently covers, or
to expand Cody to cover more workflows. Before opening a feature, try to find
another issue that describes something similar to what you want. If you can't
find something similar, then please open a new issue.

When opening a feature request, please try to include the following information:

* What do you want to do and how to you want Cody to help you do it?
* How do you think this can be added to Cody?
* What are some possible alternatives?
* What are some disadvantages?

Feature requests are marked with the label `T-enhancement`.

## Contributing Code

### Dependency Setup

For local development, Cody requires:

* Ruby
* Bundler
* Postgres
* Node
* Yarn
* Redis

Run `bundle install` to install the gem dependencies, and `bin/yarn install` to
install the Javascript dependencies.

### Environment

Copy the `.env.sample` file to `.env` and edit to replace the values there.

There are a lot of environment variables that Cody uses for different purposes.
The following table tries to summarize them all.

| Var                                      | Description                                            |
|------------------------------------------|--------------------------------------------------------|
| `CODY_GITHUB_ACCESS_TOKEN`               | Regular personal access token                          |
| `CODY_GITHUB_INTEGRATION_IDENTIFIER`     | GitHub App ID                                          |
| `CODY_GITHUB_INTEGRATION_CLIENT_ID`      | GitHub App OAuth client ID                             |
| `CODY_GITHUB_INTEGRATION_CLIENT_SECRET`  | GitHub App OAuth client secret                         |
| `CODY_GITHUB_INTEGRATION_WEBHOOK_SECRET` | Webhook secret for webhooks received by the GitHub App |
| `CODY_GITHUB_PRIVATE_KEY`                | Contents of the GitHub App .pem file                   |
| `CODY_GITHUB_PRIVATE_KEY_PATH`           | Path to the GitHub App .pem file                       |

### Setup Personal Access Token

Historically, Cody used a personal access token to authenticate with the GitHub
API.

Set up a personal access token for Cody by following [these steps](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/#creating-a-token)
from the GitHub Help guide.

### Setup GitHub App

Cody uses a [GitHub App](https://developer.github.com/apps/) to perform OAuth
authorization of users.

1. [Set up a new GitHub App](https://github.com/settings/apps/new)
2. For **User authorization callback URL** use
   `http://localhost:3000/auth/github/callback`, or whatever port you want to
   use to start the server.
3. For **Webhook URL** use `http://localhost:3000/webhooks/integration`
4. For **Webhook secret** generate a secret with `bin/rails secret`. Also place
   this secret in the `CODY_GITHUB_INTEGRATION_WEBHOOK_SECRET` environment
   variable.
5. Generate a private key for your App in the **Private Key** section and
   download the .pem file. Set one of:

   * `CODY_GITHUB_PRIVATE_KEY` to the contents of the .pem file
   * or, `CODY_GITHUB_PRIVATE_KEY_PATH` to the path to the .pem file

   These two variables are mutually exclusive, and `CODY_GITHUB_PRIVATE_KEY`
   takes precedence.
6. Copy the **ID** in the right-hand sidebar into the
   `CODY_GITHUB_INTEGRATION_IDENTIFIER` environment variable.
7. Copy the credentials from the **OAuth credentials** section into the
   corresponding environment variables.

### Running the App

Run `bin/rails s` to start the Rails server.

Run `bin/webpack-dev-server --hot` to compile all the Webpack assets and start
the Webpack dev server.

Run `bin/sidekiq` to start the Sidekiq background worker.

### Submitting Pull Requests

1. Fork the repository
2. Checkout a new branch
3. Make your changes
4. Write tests
5. Push your branch to your fork
6. Open a Pull Request

Pull Requests are checked for style by RuboCop (for Ruby code) and by ESLint
(for Javascript code). You can find the configuration files for these tools in
the repository, and you are encouraged to run them locally before submitting to
fix potential problems beforehand. We generally won't accept code that raises
any lint warnings.

For Javscript code, in addition to ESLint, you are encouraged to use Prettier
to auto-format your code. This helps keep the style consistent in Javascript
with minimal friction.
