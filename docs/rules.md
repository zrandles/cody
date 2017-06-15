# Rules

**Review Rules** are the primary way you configure Cody to enforce your team's
specific code review process.

In general, a Review Rule encapsulates a reviewer and a condition. Rules are
checked against incoming Pull Requests, and when the condition matches, the
Rule's reviewer is added automatically.

Different types of Review Rules have different possible conditions.

## Always

Always Rules unconditionally apply to every Pull Request.

## Diff Match

Diff Match Rules are used to match Pull Requests based on the contents of the
PR's combined diff.

## File Match

File Match Rules are used to match Pull Requests based on the paths of changed
files in the PR.
