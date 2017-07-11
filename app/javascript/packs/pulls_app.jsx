import React from "react";
import ReactDOM from "react-dom";
import App from "pulls/components/App";
import { AppContainer } from "react-hot-loader";

const hotRender = Component => {
  ReactDOM.render(
    <AppContainer>
      <Component />
    </AppContainer>,
    document.getElementById("pull_request_mount")
  );
};

hotRender(App);

if (module.hot) {
  module.hot.accept("pulls/components/App", () => {
    hotRender(App);
  });
}
