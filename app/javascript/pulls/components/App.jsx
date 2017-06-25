// @flow

import React from "react";
import { BrowserRouter, Route, Switch } from "react-router-dom";
import PullRequestList from "./PullRequestList";
import PullRequestDetail from "./PullRequestDetail";

const App = () =>
  <BrowserRouter>
    <Switch>
      <Route exact path="/" component={PullRequestList} />
      <Route
        exact
        path="/repos/:owner/:repo/pull/:number"
        component={PullRequestDetail}
      />
    </Switch>
  </BrowserRouter>;

export default App;
