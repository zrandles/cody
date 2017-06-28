// @flow

import React from "react";
import cn from "lib/cn";
import { type PullRequestType } from "../types";
import { Link } from "react-router-dom";
import gql from "graphql-tag";

const PullRequest = ({ number, repository, status }: PullRequestType) =>
  <div className={cn("-pull-request")}>
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
      className={cn("-pull-request--more more-button")}
    >
      &bull; &bull; &bull;
    </Link>
  </div>;

PullRequest.fragments = {
  pullRequest: gql`
    fragment PullRequest_pullRequest on PullRequest {
      id,
      repository,
      number,
      status
    }
  `
};

export default PullRequest;
