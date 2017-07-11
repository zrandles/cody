// @flow

import { Network, Environment, RecordSource, Store } from "relay-runtime";

export default function makeEnvironment(csrfToken: ?string) {
  function fetchQuery(operation, variables) {
    return fetch("/graphql", {
      method: "POST",
      credentials: "same-origin",
      headers: {
        "X-CSRF-Token": typeof csrfToken == "string" ? csrfToken : "",
        "content-type": "application/json"
      },
      body: JSON.stringify({
        query: operation.text, // GraphQL text from input
        variables
      })
    }).then(response => {
      return response.json();
    });
  }

  const network = Network.create(fetchQuery);

  return new Environment({
    network,
    store: new Store(new RecordSource())
  });
}
