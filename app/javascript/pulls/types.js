// @flow

export type PullRequestType = {
  number: string,
  repository: string,
  status: "pending_review" | "approved"
};
