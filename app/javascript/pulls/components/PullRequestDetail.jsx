// @flow

import React from "react";
import gql from "graphql-tag";
import { graphql } from "react-apollo";

const PullRequestDetail = ({ data: { loading, pullRequest } }: Object) => {
  if (loading) {
    return <div>Loading</div>;
  }
  return (
    <div className="pa4 mw6 center br2 ba b--light-gray mt4 bg-white">
      <h1 className="f3 code near-black mt0">
        {`${pullRequest.repository}#${pullRequest.number}`}
      </h1>
      <span className="code gray f4">{pullRequest.status}</span>
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
