#!/usr/bin/env bash
set -euo pipefail

if [[ "${EVENT_NAME:-}" != "pull_request" ]]; then
  echo "Branch policy applies to pull requests."
  exit 0
fi

base="${PR_BASE:-}"
head="${PR_HEAD:-}"
head_repo="${PR_HEAD_REPO:-}"
target_repo="${TARGET_REPO:-}"
work_branch='^(feature|fix|chore|ci|docs|test|refactor)/[a-z0-9]+(-[a-z0-9]+)*$'
hotfix_branch='^hotfix/[a-z0-9]+(-[a-z0-9]+)*$'
release_branch='^release/[a-z0-9]+(-[a-z0-9]+)*$'

same_repo=false
if [[ -n "$target_repo" && "$head_repo" == "$target_repo" ]]; then
  same_repo=true
fi

case "$base" in
  develop)
    if [[ "$head" =~ $work_branch ]]; then
      echo "Valid work branch into develop."
      exit 0
    fi
    if [[ "$same_repo" == true && "$head" == main ]]; then
      echo "Valid main-to-develop synchronization."
      exit 0
    fi
    ;;
  main)
    if [[ "$same_repo" == true ]] && {
      [[ "$head" == develop ]] ||
      [[ "$head" =~ $hotfix_branch ]] ||
      [[ "$head" =~ $release_branch ]]
    }; then
      echo "Valid release or hotfix into main."
      exit 0
    fi
    ;;
esac

echo "::error::Invalid PR direction or branch name. Follow CONTRIBUTING.md."
exit 1
