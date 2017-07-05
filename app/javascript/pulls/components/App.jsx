// @flow

import React from "react";
import PullRequestList from "./PullRequestList";
import PullRequestDetail from "./PullRequestDetail";
import { QueryRenderer, graphql } from "react-relay";
import { Network, Environment, RecordSource, Store } from "relay-runtime";
import { BrowserRouter, Route, Switch } from "react-router-dom";

const csrfToken = document
  .getElementsByName("csrf-token")[0]
  .getAttribute("content");

function fetchQuery(operation, variables) {
  return fetch("/graphql", {
    method: "POST",
    credentials: "same-origin",
    headers: {
      "X-CSRF-Token": typeof csrfToken == "string" ? csrfToken : "",
      "content-type": "application/json"
    },
    body: JSON.stringify({
      query: operation.text, // GraphQL text from input
      variables
    })
  }).then(response => {
    return response.json();
  });
}

const network = Network.create(fetchQuery);

const environment = new Environment({
  network,
  store: new Store(new RecordSource())
});

const App = () =>
  <BrowserRouter>
    <Switch>
      <Route
        exact
        path="/repos/:owner/:name"
        render={({ match }) => {
          return (
            <QueryRenderer
              environment={environment}
              query={graphql`
                query App_List_Query($owner: String!, $name: String!, $cursor: String) {
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
                  return <div>{error.message}</div>;
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
                query App_Detail_Query($owner: String!, $name: String!, $number: String!) {
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
                  return <div>{error.message}</div>;
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
    </Switch>
  </BrowserRouter>;

export default App;
