// @flow

import React from "react";
import { BrowserRouter, Route, Switch } from "react-router-dom";
import PullRequestList from "./PullRequestList";
import PullRequestDetail from "./PullRequestDetail";
import gql from "graphql-tag";
import { graphql } from "react-apollo";

const PullRequestListWithData = graphql(
  gql`
    query PullRequestListWithData($owner: String!, $name: String!, $status: String!) {
      repository(owner: $owner, name: $name) {
        ...PullRequestList_repository
      }
    }
    ${PullRequestList.fragments.repository}
  `,
  {
    options: ({ match }) => ({
      variables: {
        owner: match.params.owner,
        name: match.params.repo,
        status: "pending_review"
      }
    })
  }
)(PullRequestList);

const App = () =>
  <BrowserRouter>
    <Switch>
      <Route
        exact
        path="/repos/:owner/:repo"
        component={PullRequestListWithData}
      />
      <Route
        exact
        path="/repos/:owner/:repo/pull/:number"
        component={PullRequestDetail}
      />
    </Switch>
  </BrowserRouter>;

export default App;
