import React from "react";
import ReactDOM from "react-dom";
import {
  ApolloClient,
  ApolloProvider,
  createNetworkInterface
} from "react-apollo";
import VisiblePullRequests from "pulls/containers/VisiblePullRequests";
import { AppContainer } from "react-hot-loader";

const csrfToken = document.getElementsByName("csrf-token")[0].content;
const client = new ApolloClient({
  networkInterface: createNetworkInterface({
    uri: "/graphql",
    opts: {
      credentials: "same-origin",
      headers: {
        "X-CSRF-Token": csrfToken
      }
    }
  })
});

const hotRender = Component => {
  ReactDOM.render(
    <AppContainer>
      <ApolloProvider client={client}>
        <Component />
      </ApolloProvider>
    </AppContainer>,
    document.getElementById("pull_request_mount")
  );
};

document.addEventListener("DOMContentLoaded", () => {
  hotRender(VisiblePullRequests);
});

if (module.hot) {
  module.hot.accept("pulls/containers/VisiblePullRequests", () => {
    hotRender(VisiblePullRequests);
  });
}
