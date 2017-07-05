/**
 * @flow
 * @relayHash 4983d5164b9d00becdcb7bda51faadd2
 */

/* eslint-disable */

'use strict';

/*::
import type {ConcreteBatch} from 'relay-runtime';
export type App_Detail_QueryResponse = {|
  +viewer: ?{|
    +repository: ?{|
      +pullRequest: ?{| |};
    |};
  |};
|};
*/


/*
query App_Detail_Query(
  $owner: String!
  $name: String!
  $number: String!
) {
  viewer {
    repository(owner: $owner, name: $name) {
      pullRequest(number: $number) {
        ...PullRequestDetail_pullRequest
        id
      }
      id
    }
    id
  }
}

fragment PullRequestDetail_pullRequest on PullRequest {
  id
  repository
  number
  status
  reviewers {
    edges {
      node {
        ...Reviewer_reviewer
        id
      }
    }
  }
}

fragment Reviewer_reviewer on Reviewer {
  id
  login
  status
}
*/

const batch /*: ConcreteBatch*/ = {
  "fragment": {
    "argumentDefinitions": [
      {
        "kind": "LocalArgument",
        "name": "owner",
        "type": "String!",
        "defaultValue": null
      },
      {
        "kind": "LocalArgument",
        "name": "name",
        "type": "String!",
        "defaultValue": null
      },
      {
        "kind": "LocalArgument",
        "name": "number",
        "type": "String!",
        "defaultValue": null
      }
    ],
    "kind": "Fragment",
    "metadata": null,
    "name": "App_Detail_Query",
    "selections": [
      {
        "kind": "LinkedField",
        "alias": null,
        "args": null,
        "concreteType": "User",
        "name": "viewer",
        "plural": false,
        "selections": [
          {
            "kind": "LinkedField",
            "alias": null,
            "args": [
              {
                "kind": "Variable",
                "name": "name",
                "variableName": "name",
                "type": "String!"
              },
              {
                "kind": "Variable",
                "name": "owner",
                "variableName": "owner",
                "type": "String!"
              }
            ],
            "concreteType": "Repository",
            "name": "repository",
            "plural": false,
            "selections": [
              {
                "kind": "LinkedField",
                "alias": null,
                "args": [
                  {
                    "kind": "Variable",
                    "name": "number",
                    "variableName": "number",
                    "type": "String!"
                  }
                ],
                "concreteType": "PullRequest",
                "name": "pullRequest",
                "plural": false,
                "selections": [
                  {
                    "kind": "FragmentSpread",
                    "name": "PullRequestDetail_pullRequest",
                    "args": null
                  }
                ],
                "storageKey": null
              }
            ],
            "storageKey": null
          }
        ],
        "storageKey": null
      }
    ],
    "type": "Query"
  },
  "id": null,
  "kind": "Batch",
  "metadata": {},
  "name": "App_Detail_Query",
  "query": {
    "argumentDefinitions": [
      {
        "kind": "LocalArgument",
        "name": "owner",
        "type": "String!",
        "defaultValue": null
      },
      {
        "kind": "LocalArgument",
        "name": "name",
        "type": "String!",
        "defaultValue": null
      },
      {
        "kind": "LocalArgument",
        "name": "number",
        "type": "String!",
        "defaultValue": null
      }
    ],
    "kind": "Root",
    "name": "App_Detail_Query",
    "operation": "query",
    "selections": [
      {
        "kind": "LinkedField",
        "alias": null,
        "args": null,
        "concreteType": "User",
        "name": "viewer",
        "plural": false,
        "selections": [
          {
            "kind": "LinkedField",
            "alias": null,
            "args": [
              {
                "kind": "Variable",
                "name": "name",
                "variableName": "name",
                "type": "String!"
              },
              {
                "kind": "Variable",
                "name": "owner",
                "variableName": "owner",
                "type": "String!"
              }
            ],
            "concreteType": "Repository",
            "name": "repository",
            "plural": false,
            "selections": [
              {
                "kind": "LinkedField",
                "alias": null,
                "args": [
                  {
                    "kind": "Variable",
                    "name": "number",
                    "variableName": "number",
                    "type": "String!"
                  }
                ],
                "concreteType": "PullRequest",
                "name": "pullRequest",
                "plural": false,
                "selections": [
                  {
                    "kind": "ScalarField",
                    "alias": null,
                    "args": null,
                    "name": "id",
                    "storageKey": null
                  },
                  {
                    "kind": "ScalarField",
                    "alias": null,
                    "args": null,
                    "name": "repository",
                    "storageKey": null
                  },
                  {
                    "kind": "ScalarField",
                    "alias": null,
                    "args": null,
                    "name": "number",
                    "storageKey": null
                  },
                  {
                    "kind": "ScalarField",
                    "alias": null,
                    "args": null,
                    "name": "status",
                    "storageKey": null
                  },
                  {
                    "kind": "LinkedField",
                    "alias": null,
                    "args": null,
                    "concreteType": "ReviewerConnection",
                    "name": "reviewers",
                    "plural": false,
                    "selections": [
                      {
                        "kind": "LinkedField",
                        "alias": null,
                        "args": null,
                        "concreteType": "ReviewerEdge",
                        "name": "edges",
                        "plural": true,
                        "selections": [
                          {
                            "kind": "LinkedField",
                            "alias": null,
                            "args": null,
                            "concreteType": "Reviewer",
                            "name": "node",
                            "plural": false,
                            "selections": [
                              {
                                "kind": "ScalarField",
                                "alias": null,
                                "args": null,
                                "name": "id",
                                "storageKey": null
                              },
                              {
                                "kind": "ScalarField",
                                "alias": null,
                                "args": null,
                                "name": "login",
                                "storageKey": null
                              },
                              {
                                "kind": "ScalarField",
                                "alias": null,
                                "args": null,
                                "name": "status",
                                "storageKey": null
                              }
                            ],
                            "storageKey": null
                          }
                        ],
                        "storageKey": null
                      }
                    ],
                    "storageKey": null
                  }
                ],
                "storageKey": null
              },
              {
                "kind": "ScalarField",
                "alias": null,
                "args": null,
                "name": "id",
                "storageKey": null
              }
            ],
            "storageKey": null
          },
          {
            "kind": "ScalarField",
            "alias": null,
            "args": null,
            "name": "id",
            "storageKey": null
          }
        ],
        "storageKey": null
      }
    ]
  },
  "text": "query App_Detail_Query(\n  $owner: String!\n  $name: String!\n  $number: String!\n) {\n  viewer {\n    repository(owner: $owner, name: $name) {\n      pullRequest(number: $number) {\n        ...PullRequestDetail_pullRequest\n        id\n      }\n      id\n    }\n    id\n  }\n}\n\nfragment PullRequestDetail_pullRequest on PullRequest {\n  id\n  repository\n  number\n  status\n  reviewers {\n    edges {\n      node {\n        ...Reviewer_reviewer\n        id\n      }\n    }\n  }\n}\n\nfragment Reviewer_reviewer on Reviewer {\n  id\n  login\n  status\n}\n"
};

module.exports = batch;
