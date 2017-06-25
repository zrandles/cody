// @flow

import React from "react";
import { type PullRequestType } from "../types";
import gql from "graphql-tag";
import { graphql } from "react-apollo";

const PullRequestDetail = ({ data: { loading, pullRequest } }: Object) => {
  if (loading) {
    return <div>Loading</div>;
  }
  return (
    <div>
      {pullRequest.number}
    </div>
  );
};

const pullRequestQuery = gql`
  query GetPullRequest($repository: String!, $number: String!) {
    pullRequest(repository: $repository, number: $number) {
      number,
      repository,
      status
    }
  }
`;

const withPullRequestData = graphql(pullRequestQuery, {
  options: props => ({
    variables: {
      repository: `${props.match.params.owner}/${props.match.params.repo}`,
      number: props.match.params.number
    }
  })
});

export default withPullRequestData(PullRequestDetail);
