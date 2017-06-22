// @flow

import PullRequestList from "../components/PullRequestList";
import { type Props as PullRequestProps } from "../components/PullRequest";
import { connect } from "react-redux";

const mapStateToProps = ({
  pull_requests
}: {
  pull_requests: Array<PullRequestProps>
}) => ({ pull_requests });

export default connect(mapStateToProps)(PullRequestList);
