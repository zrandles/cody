// @flow

import React from "react";
import Nav from "./Nav";
import PullRequestList from "./PullRequestList";
import PullRequestDetail from "./PullRequestDetail";
import RepositoryList from "./RepositoryList";
import makeEnvironment from "../makeEnvironment";
import { QueryRenderer, graphql } from "react-relay";
import { BrowserRouter, Redirect, Route, Switch } from "react-router-dom";

const csrfToken = document
  .getElementsByName("csrf-token")[0]
  .getAttribute("content");

const environment = makeEnvironment(csrfToken);

const App = () =>
  <BrowserRouter>
    <div>
      <Nav />
      <Switch>
        <Route
          exact
          path="/repos"
          render={() => {
            return (
              <QueryRenderer
                environment={environment}
                query={graphql`
                  query App_RepoList_Query {
                    viewer {
                      ...RepositoryList_viewer
                    }
                  }
                `}
                render={({ error, props }) => {
                  if (error) {
                    return (
                      <div>
                        {error.message}
                      </div>
                    );
                  } else if (props) {
                    return <RepositoryList viewer={props.viewer} />;
                  }
                  return <div>Loading</div>;
                }}
              />
            );
          }}
        />
        <Route
          exact
          path="/repos/:owner/:name/pulls"
          render={({ match }) => {
            return (
              <QueryRenderer
                environment={environment}
                query={graphql`
                  query App_List_Query(
                    $owner: String!
                    $name: String!
                    $cursor: String
                  ) {
                    viewer {
                      repository(owner: $owner, name: $name) {
                        ...PullRequestList_repository
                      }
                      login
                      name
                    }
                  }
                `}
                variables={{
                  owner: match.params.owner,
                  name: match.params.name
                }}
                render={({ error, props }) => {
                  if (error) {
                    return (
                      <div>
                        {error.message}
                      </div>
                    );
                  } else if (props) {
                    return (
                      <PullRequestList repository={props.viewer.repository} />
                    );
                  }
                  return <div>Loading</div>;
                }}
              />
            );
          }}
        />
        <Route
          exact
          path="/repos/:owner/:name/pull/:number"
          render={({ match }) => {
            return (
              <QueryRenderer
                environment={environment}
                query={graphql`
                  query App_Detail_Query(
                    $owner: String!
                    $name: String!
                    $number: String!
                  ) {
                    viewer {
                      repository(owner: $owner, name: $name) {
                        pullRequest(number: $number) {
                          ...PullRequestDetail_pullRequest
                        }
                      }
                    }
                  }
                `}
                variables={{
                  owner: match.params.owner,
                  name: match.params.name,
                  number: match.params.number
                }}
                render={({ error, props }) => {
                  if (error) {
                    return (
                      <div>
                        {error.message}
                      </div>
                    );
                  } else if (props) {
                    return (
                      <PullRequestDetail
                        pullRequest={props.viewer.repository.pullRequest}
                      />
                    );
                  }
                  return <div>Loading</div>;
                }}
              />
            );
          }}
        />
        <Route
          exact
          path="/repos/:owner/:name"
          render={({ match }) => {
            return (
              <Redirect
                to={`/repos/${match.params.owner}/${match.params.name}/pulls`}
              />
            );
          }}
        />
        <Redirect from="/" to="/repos" />
      </Switch>
    </div>
  </BrowserRouter>;

export default App;
