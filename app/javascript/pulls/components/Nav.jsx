// @flow

import React from "react";
import Icon from "./Icon";
import { NavLink } from "react-router-dom";

const Nav = () =>
  <nav className="nav has-shadow">
    <div className="container">
      <div className="nav-left">
        <NavLink to="/" className="nav-item" activeClassName="is-active">
          <strong>Cody</strong>
          &nbsp;
          <Icon icon="code" size="medium" />
        </NavLink>
        <NavLink
          to="/repos"
          className="nav-item is-tab"
          activeClassName="is-active"
        >
          Repos
        </NavLink>
      </div>
    </div>
  </nav>;

export default Nav;
