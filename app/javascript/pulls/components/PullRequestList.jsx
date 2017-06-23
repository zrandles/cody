// @flow

import React from "react";
import PullRequest, { type Props as PullRequestProps } from "./PullRequest";

type Props = {
  data: {
    pullRequests: Array<PullRequestProps>
  }
};

const PullRequestList = ({ data }: Props) => {
  if (data.networkStatus === 1) {
    return <div>Loading</div>;
  }

  return (
    <div>
      {data.pullRequests.map(pull_request => {
        return <PullRequest key={pull_request.number} {...pull_request} />;
      })}
    </div>
  );
};

export default PullRequestList;
