import React from "react";
import ReactDOM from "react-dom";
import { createStore } from "redux";
import VisiblePullRequests from "pulls/containers/VisiblePullRequests";
import { Provider } from "react-redux";
import { AppContainer } from "react-hot-loader";

let initialState = {
  pull_requests: [
    {
      number: "42"
    },
    {
      number: "69"
    }
  ]
};

let store = createStore(state => state, initialState);

const hotRender = Component => {
  ReactDOM.render(
    <AppContainer>
      <Provider store={store}>
        <Component />
      </Provider>
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
