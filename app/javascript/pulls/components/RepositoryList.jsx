// @flow

import React from "react";
import Repository from "./Repository";
import { createFragmentContainer, graphql } from "react-relay";

const RepositoryList = ({ viewer }) =>
  <section className="section">
    <div className="container">
      {viewer.repositories.edges.map(edge => {
        return <Repository key={edge.node.id} repository={edge.node} />;
      })}
    </div>
  </section>;

export default createFragmentContainer(
  RepositoryList,
  graphql`
    fragment RepositoryList_viewer on User {
      repositories(first: 10) {
        edges {
          node {
            ...Repository_repository
          }
        }
      }
    }
  `
);
