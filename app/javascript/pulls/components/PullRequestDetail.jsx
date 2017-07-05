// @flow

import React from "react";
import Reviewer from "./Reviewer";
import { createFragmentContainer, graphql } from "react-relay";
import { type PullRequestDetail_pullRequest } from "./__generated__/PullRequestDetail_pullRequest.graphql";

const PullRequestDetail = ({
  pullRequest
}: {
  pullRequest: PullRequestDetail_pullRequest
}) => {
  return (
    <div className="mw6 center">
      <div className="pa4 br2 ba b--light-gray mt4 bg-white">
        <h1 className="f3 code near-black mt0">
          {`${pullRequest.repository}#${pullRequest.number}`}
        </h1>
        <span className="code gray f4">{pullRequest.status}</span>
      </div>
      <div className="mt4">
        {pullRequest.reviewers.edges.map(edge => {
          return <Reviewer reviewer={edge.node} key={edge.node.id} />;
        })}
      </div>
    </div>
  );
};

export default createFragmentContainer(
  PullRequestDetail,
  graphql`
    fragment PullRequestDetail_pullRequest on PullRequest {
      id
      repository
      number
      status
      reviewers {
        edges {
          node {
            ...Reviewer_reviewer
          }
        }
      }
    }
  `
);
