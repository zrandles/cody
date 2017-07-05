// @flow

import React from "react";
import { createFragmentContainer, graphql } from "react-relay";
import { type PullRequestDetail_pullRequest } from "./__generated__/PullRequestDetail_pullRequest.graphql";

const PullRequestDetail = ({
  pullRequest
}: {
  pullRequest: PullRequestDetail_pullRequest
}) => {
  return (
    <div className="pa4 mw6 center br2 ba b--light-gray mt4 bg-white">
      <h1 className="f3 code near-black mt0">
        {`${pullRequest.repository}#${pullRequest.number}`}
      </h1>
      <span className="code gray f4">{pullRequest.status}</span>
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
    }
  `
);
