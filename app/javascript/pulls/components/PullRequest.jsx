// @flow

import React from "react";
import cn from "lib/cn";

export type Props = {
  number: string,
  repository: string,
  status: "pending_review" | "approved"
};

const PullRequest = ({ number, repository, status }: Props) =>
  <div className={cn("-pull-request")}>
    <div>
      <div className="dib pv1 f4 code near-black lh-copy">
        {`${repository}#${number}`}
      </div>
      <div className="dib pv1 f4 code gray mh3 lh-copy">
        {status}
      </div>
    </div>
    <a href="#" className={cn("-pull-request--more more-button")}>
      &bull; &bull; &bull;
    </a>
  </div>;

export default PullRequest;
