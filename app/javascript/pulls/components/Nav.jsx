// @flow

import React from "react";
import Icon from "./Icon";
import { NavLink } from "react-router-dom";

class Nav extends React.Component {
  render() {
    return (
      <div className="navbar-container">
        <div className="container">
          <nav className="navbar">
            <div className="navbar-brand">
              <NavLink to="/" className="nav-item" activeClassName="is-active">
                <strong>Cody</strong>
                &nbsp;
                <Icon icon="code" size="medium" />
              </NavLink>
              <div className="navbar-burger burger" data-target="navMenu">
                <span />
                <span />
                <span />
              </div>
            </div>
            <div id="navMenu" className="navbar-menu">
              <div className="navbar-start">
                <NavLink
                  to="/repos"
                  className="nav-item is-tab"
                  activeClassName="is-active"
                >
                  Repos
                </NavLink>
              </div>
            </div>
          </nav>
        </div>
      </div>
    );
  }
}

export default Nav;
