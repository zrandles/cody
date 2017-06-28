// @flow

import React from "react";
import gql from "graphql-tag";
import { graphql } from "react-apollo";
import PullRequest from "./PullRequest";

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

export default graphql(
  gql`
    query PullRequestDetailQuery($repository: String!, $number: String!) {
      pullRequest(repository: $repository, number: $number) {
        ...PullRequest_pullRequest
      }
    }
    ${PullRequest.fragments.pullRequest}
  `,
  {
    options: ({ match }) => ({
      variables: {
        repository: `${match.params.owner}/${match.params.repo}`,
        number: match.params.number
      }
    })
  }
)(PullRequestDetail);
