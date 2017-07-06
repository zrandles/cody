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
    <section className="section">
      <div className="container box code">
        <div className="pa4 br2 ba b--light-gray mt4 bg-white">
          <h1 className="title code">
            {`${pullRequest.repository}#${pullRequest.number}`}
          </h1>
          <h2 className="subtitle code">
            {pullRequest.status}
          </h2>
        </div>
        <hr />
        <div>
          {pullRequest.reviewers != null && pullRequest.reviewers.edges != null
            ? pullRequest.reviewers.edges.map(edge => {
                if (edge != null && edge.node != null) {
                  // https://github.com/facebook/relay/issues/1918
                  return <Reviewer key={edge.node.id} reviewer={edge.node} />;
                }
              })
            : null}
        </div>
      </div>
    </section>
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
            id
            ...Reviewer_reviewer
          }
        }
      }
    }
  `
);
