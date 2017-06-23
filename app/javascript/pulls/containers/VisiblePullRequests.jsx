// @flow

import PullRequestList from "../components/PullRequestList";
import { gql, graphql } from "react-apollo";

const pullRequestsQuery = gql`
  query {
    pullRequests(repository: "aergonaut/testrepo", status: pending_review) {
      number,
      repository
    }
  }
`;

export default graphql(pullRequestsQuery)(PullRequestList);
