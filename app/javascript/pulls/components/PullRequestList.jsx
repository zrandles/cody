// @flow

import React from "react";
import PullRequest from "./PullRequest";
import gql from "graphql-tag";

const PullRequestList = ({ data }: Object) => {
  if (data.networkStatus === 1) {
    return <div>Loading</div>;
  }

  return (
    <div>
      {data.repository.pullRequests.edges.map(edge => {
        const pullRequest = edge.node;
        return <PullRequest key={pullRequest.id} {...pullRequest} />;
      })}
    </div>
  );
};

PullRequestList.fragments = {
  repository: gql`
    fragment PullRequestList_repository on Repository {
      pullRequests(status: $status) {
        edges {
          node {
            ...PullRequest_pullRequest
          }
        }
      }
    }
    ${PullRequest.fragments.pullRequest}
  `
};

export default PullRequestList;
