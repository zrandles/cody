/**
 * @flow
 * @relayHash b46cec601f6685a1627c008361c9d451
 */

/* eslint-disable */

'use strict';

/*::
import type {ConcreteBatch} from 'relay-runtime';
export type App_RepoList_QueryResponse = {|
  +viewer: ?{| |};
|};
*/


/*
query App_RepoList_Query {
  viewer {
    ...RepositoryList_viewer
    id
  }
}

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

fragment Repository_repository on Repository {
  id
  owner
  name
}
*/

const batch /*: ConcreteBatch*/ = {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "App_RepoList_Query",
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
            "kind": "FragmentSpread",
            "name": "RepositoryList_viewer",
            "args": null
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
  "name": "App_RepoList_Query",
  "query": {
    "argumentDefinitions": [],
    "kind": "Root",
    "name": "App_RepoList_Query",
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
                "kind": "Literal",
                "name": "first",
                "value": 10,
                "type": "Int"
              }
            ],
            "concreteType": "RepositoryConnection",
            "name": "repositories",
            "plural": false,
            "selections": [
              {
                "kind": "LinkedField",
                "alias": null,
                "args": null,
                "concreteType": "RepositoryEdge",
                "name": "edges",
                "plural": true,
                "selections": [
                  {
                    "kind": "LinkedField",
                    "alias": null,
                    "args": null,
                    "concreteType": "Repository",
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
                        "name": "owner",
                        "storageKey": null
                      },
                      {
                        "kind": "ScalarField",
                        "alias": null,
                        "args": null,
                        "name": "name",
                        "storageKey": null
                      }
                    ],
                    "storageKey": null
                  }
                ],
                "storageKey": null
              }
            ],
            "storageKey": "repositories{\"first\":10}"
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
  "text": "query App_RepoList_Query {\n  viewer {\n    ...RepositoryList_viewer\n    id\n  }\n}\n\nfragment RepositoryList_viewer on User {\n  repositories(first: 10) {\n    edges {\n      node {\n        id\n        ...Repository_repository\n      }\n    }\n  }\n}\n\nfragment Repository_repository on Repository {\n  id\n  owner\n  name\n}\n"
};

module.exports = batch;
