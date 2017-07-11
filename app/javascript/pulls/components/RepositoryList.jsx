// @flow

import React from "react";
import Repository from "./Repository";
import { createFragmentContainer, graphql } from "react-relay";
import type { RepositoryList_viewer } from "./__generated__/RepositoryList_viewer.graphql";

const RepositoryList = ({ viewer }: { viewer: RepositoryList_viewer }) =>
  <section className="section">
    <div className="container">
      {viewer.repositories != null && viewer.repositories.edges != null
        ? viewer.repositories.edges.map(edge => {
            if (edge != null && edge.node != null) {
              // https://github.com/facebook/relay/issues/1918
              return <Repository key={edge.node.id} repository={edge.node} />;
            }
          })
        : null}
    </div>
  </section>;

export default createFragmentContainer(
  RepositoryList,
  graphql`
    fragment RepositoryList_viewer on User {
      repositories(first: 10) {
        edges {
          node {
            id
            ...Repository_repository
          }
        }
      }
    }
  `
);
