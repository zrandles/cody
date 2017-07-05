// @flow

import React from "react";
import { createFragmentContainer, graphql } from "react-relay";
import { VerifiedIcon, UnverifiedIcon } from "react-octicons";

function statusToOcticon(status: string) {
  switch (status) {
    case "pending_approval":
      return <UnverifiedIcon />;
    case "approved":
      return <VerifiedIcon />;
    default:
      return status;
  }
}

const Reviewer = ({ reviewer }) =>
  <div className="pa4 bw1 br2 b--light-gray mt1 bg-white">
    <div className="dib mr3">{statusToOcticon(reviewer.status)}</div>
    <div className="dib code f4">{reviewer.login}</div>
  </div>;

export default createFragmentContainer(
  Reviewer,
  graphql`
    fragment Reviewer_reviewer on Reviewer {
      id
      login
      status
    }
  `
);
