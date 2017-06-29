// @flow

import React from "react";
import PullRequest, { type PullRequestType } from "./PullRequest";
import gql from "graphql-tag";
import { graphql } from "react-apollo";
import type { OperationComponent, QueryProps } from "react-apollo";

type RepositoryType = {
  pullRequests: {
    edges: Array<PullRequestConnection>
  }
};

type PullRequestConnection = {
  node: PullRequestType
};

type Response = {
  repository: RepositoryType
};

type InputProps = {
  match: {
    params: {
      owner: string,
      repo: string
    }
  }
};

type Props = {
  data: Response & QueryProps
};

const PullRequestList = ({ data: { networkStatus, repository } }: Props) => {
  if (networkStatus === 1) {
    return <div>Loading</div>;
  }

  return (
    <div className="mw7 center">
      {repository.pullRequests.edges.map(edge => {
        const pullRequest = edge.node;
        return <PullRequest key={pullRequest.id} {...pullRequest} />;
      })}
    </div>
  );
};

PullRequestList.fragments = {
  repository: gql`
    fragment PullRequestList_repository on Repository {
      pullRequests(status: $status, first: 10, after: $cursor) {
        edges {
          node {
            ...PullRequest_pullRequest
          }
        }
        pageInfo {
          hasNextPage,
          endCursor
        }
      }
    }
    ${PullRequest.fragments.pullRequest}
  `
};

const withData: OperationComponent<Response, InputProps, Props> = graphql(
  gql`
    query PullRequestListWithData($owner: String!, $name: String!, $status: String!, $cursor: String) {
      repository(owner: $owner, name: $name) {
        ...PullRequestList_repository
      }
    }
    ${PullRequestList.fragments.repository}
  `,
  {
    options: ({ match }) => ({
      variables: {
        owner: match.params.owner,
        name: match.params.repo,
        status: "pending_review"
      }
    })
  }
);

export default withData(PullRequestList);
