/**
 * @flow
 */

/* eslint-disable */

'use strict';

/*::
import type {ConcreteFragment} from 'relay-runtime';
export type PullRequestList_repository = {|
  +pullRequests: ?{|
    +edges: ?$ReadOnlyArray<?{|
      +node: ?{|
        +id: string;
      |};
    |}>;
  |};
  +id: string;
|};
*/


const fragment /*: ConcreteFragment*/ = {
  "argumentDefinitions": [
    {
      "kind": "RootArgument",
      "name": "cursor",
      "type": "String"
    }
  ],
  "kind": "Fragment",
  "metadata": {
    "connection": [
      {
        "count": null,
        "cursor": "cursor",
        "direction": "forward",
        "path": [
          "pullRequests"
        ]
      }
    ]
  },
  "name": "PullRequestList_repository",
  "selections": [
    {
      "kind": "LinkedField",
      "alias": "pullRequests",
      "args": null,
      "concreteType": "PullRequestConnection",
      "name": "__PullRequestList_pullRequests_connection",
      "plural": false,
      "selections": [
        {
          "kind": "LinkedField",
          "alias": null,
          "args": null,
          "concreteType": "PullRequestEdge",
          "name": "edges",
          "plural": true,
          "selections": [
            {
              "kind": "LinkedField",
              "alias": null,
              "args": null,
              "concreteType": "PullRequest",
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
                  "kind": "FragmentSpread",
                  "name": "PullRequest_pullRequest",
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
    },
    {
      "kind": "ScalarField",
      "alias": null,
      "args": null,
      "name": "id",
      "storageKey": null
    }
  ],
  "type": "Repository"
};

module.exports = fragment;
