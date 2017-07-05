// @flow

import React from "react";
import { createFragmentContainer, graphql } from "react-relay";

function statusToOcticon(status: string) {
  switch (status) {
    case "pending_approval":
      return (
        <span className="icon">
          <i className="fa fa-square-o" />
        </span>
      );
    case "approved":
      return (
        <span className="icon">
          <i className="fa fa-check-square-o" />
        </span>
      );
    default:
      return status;
  }
}

const Reviewer = ({ reviewer }) =>
  <div className="level">
    <div className="level-left">
      <div className="level-item">
        {statusToOcticon(reviewer.status)}
      </div>
      <div className="level-item">
        {reviewer.login}
      </div>
    </div>
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
