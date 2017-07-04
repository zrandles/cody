// @flow

import React from "react";
import PullRequest, { type PullRequestType } from "./PullRequest";
import gql from "graphql-tag";
import { graphql } from "react-apollo";
import type { OperationComponent, QueryProps } from "react-apollo";

type RepositoryType = {
  id: string,
  owner: string,
  name: string,
  pullRequests: {
    edges: Array<PullRequestConnection>,
    pageInfo: {
      hasNextPage: boolean,
      endCursor: string
    }
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
  data: Response & QueryProps,
  loadMore: () => mixed
};

const PullRequestList = ({
  data: { loading, repository },
  loadMore
}: Props) => {
  console.log(repository);
  if (loading) {
    return <div>Loading</div>;
  }

  return (
    <div className="mw7 center">
      {repository.pullRequests.edges.map(edge => {
        const pullRequest = edge.node;
        return <PullRequest key={pullRequest.id} {...pullRequest} />;
      })}
      <div onClick={loadMore}>
        More
      </div>
    </div>
  );
};

PullRequestList.fragments = {
  repository: gql`
    fragment PullRequestList_repository on Repository {
      id,
      owner,
      name,
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
    }),
    props: ({ data }) => {
      if (data != null) {
        let myData = data;

        return {
          data: myData,
          loadMore: () => {
            return myData.fetchMore({
              variables: {
                owner: myData.repository.owner,
                name: myData.repository.name,
                curosr: myData.repository.pullRequests.pageInfo.endCursor
              },
              updateQuery: (previousResult, { fetchMoreResult }) => {
                const newEdges = fetchMoreResult.repository.pullRequests.edges;
                const pageInfo =
                  fetchMoreResult.repository.pullRequests.pageInfo;

                let nextResult = {
                  ...previousResult,
                  repository: {
                    pullRequests: {
                      edges: [
                        ...previousResult.repository.pullRequests.edges,
                        ...newEdges
                      ],
                      pageInfo
                    }
                  }
                };

                return nextResult;
              }
            });
          }
        };
      } else {
        throw new Error("PullRequestList used on a non-Query type query!");
      }
    }
  }
);

export default withData(PullRequestList);
