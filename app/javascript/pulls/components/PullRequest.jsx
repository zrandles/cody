// @flow

import React from "react";

export type Props = {
  number: string
};

const PullRequest = ({ number }: Props) =>
  <div>
    {number}
  </div>;

export default PullRequest;
