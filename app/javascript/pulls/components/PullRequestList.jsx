// @flow

import React from "react";
import PullRequest from "./PullRequest";
import { type PullRequestType } from "../types";
import gql from "graphql-tag";
import { graphql } from "react-apollo";

type Props = {
  data: {
    pullRequests: Array<PullRequestType>
  }
};

const PullRequestList = ({ data }: Props) => {
  if (data.networkStatus === 1) {
    return <div>Loading</div>;
  }

  return (
    <div>
      {data.pullRequests.map(pull_request => {
        return <PullRequest key={pull_request.number} {...pull_request} />;
      })}
    </div>
  );
};

const pullRequestsQuery = gql`
  query GetPullRequests {
    pullRequests(repository: "aergonaut/testrepo", status: pending_review) {
      number,
      repository,
      status
    }
  }
`;

export default graphql(pullRequestsQuery)(PullRequestList);
