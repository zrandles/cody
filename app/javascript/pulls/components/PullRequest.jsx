// @flow

import React from "react";
import { createFragmentContainer, graphql } from "react-relay";
import { Link } from "react-router-dom";
import type { PullRequest_pullRequest } from "./__generated__/PullRequest_pullRequest.graphql";

const PullRequest = ({
  pullRequest: { id, number, repository, status }
}: {
  pullRequest: PullRequest_pullRequest
}) =>
  <div className="pa4 bt bb bw1 br2 b--light-gray flex flex-row justify-between bg-white">
    <div>
      <div className="dib pv1 f4 code near-black lh-copy">
        {`${repository}#${number}`}
      </div>
      <div className="dib pv1 f4 code gray mh3 lh-copy">
        {status}
      </div>
    </div>
    <Link
      to={`/repos/${repository}/pull/${number}`}
      className="dib br2 ba b--light-silver pv2 ph3 f5 gray hover-near-black link more-button"
    >
      &bull; &bull; &bull;
    </Link>
  </div>;

export default createFragmentContainer(
  PullRequest,
  graphql`
    fragment PullRequest_pullRequest on PullRequest {
      id
      repository
      number
      status
    }
  `
);
