// @flow

import React from "react";

const Icon = ({ icon }: { icon: string }) =>
  <span className="icon">
    <i className={`fa fa-${icon}`} />
  </span>;

export default Icon;
