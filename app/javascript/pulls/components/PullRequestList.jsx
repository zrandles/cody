// @flow

import React from "react";
import PullRequest from "./PullRequest";
import { createFragmentContainer, graphql } from "react-relay";
import { type PullRequestList_repository } from "./__generated__/PullRequestList_repository.graphql";

const PullRequestList = ({
  repository
}: {
  repository: PullRequestList_repository
}) => {
  return (
    <div className="mw7 center">
      {repository.pullRequests.edges.map(edge => {
        return <PullRequest key={edge.node.id} pullRequest={edge.node} />;
      })}
    </div>
  );
};

export default createFragmentContainer(
  PullRequestList,
  graphql`
    fragment PullRequestList_repository on Repository {
      pullRequests(first: 10, after: $cursor) @connection(key: "PullRequestList_pullRequests") {
        edges {
          node {
            id
            ...PullRequest_pullRequest
          }
        }
      }
      id
    }
  `
);
