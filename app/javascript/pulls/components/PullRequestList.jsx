// @flow

import React from "react";
import PullRequest, { type Props as PullRequestProps } from "./PullRequest";

type Props = {
  pull_requests: Array<PullRequestProps>
};

const PullRequestList = ({ pull_requests }: Props) =>
  <div>
    {pull_requests.map(pull_request => {
      return <PullRequest key={pull_request.number} {...pull_request} />;
    })}
  </div>;

export default PullRequestList;
