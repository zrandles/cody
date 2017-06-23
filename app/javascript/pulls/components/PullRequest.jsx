// @flow

import React from "react";
import cn from "lib/cn";

export type Props = {
  number: string,
  repository: string
};

const PullRequest = ({ number, repository }: Props) =>
  <div className={cn("-pull-request")}>
    <div className="dib pv2 f4">
      {`${repository}#${number}`}
    </div>
    <a href="#" className={cn("-pull-request--more")}>More</a>
  </div>;

export default PullRequest;
