#!/bin/bash

# Creates a pull request url from the current branch to the parent branch. Also opens the url in
# the browser.

get_parent_ticket_branch() {
  local current_branch_type="$1"
  local currentBranch="$2"

  case "$current_branch_type" in
    release|main)
        echo "$(tput setaf 1)ERROR: Cannot align from '$current_branch_type'" >&2
        exit 1
        ;;
    *)
        echo "$(git config --get "branch.$currentBranch.parent")"
        ;;
  esac
}

get_current_branch_type() {
    local currentBranch="$1"

    IFS=/
    read -ra parts <<< "$currentBranch"  

    echo "${parts[0]}"
}
currentBranch="$(git branch --show-current)"
currentBranchType="$(get_current_branch_type "$currentBranch")"
parentBranch="$(get_parent_ticket_branch "$currentBranchType" "$currentBranch")"

git checkout "$parentBranch"
git pull --prune
git checkout "$currentBranch"
git merge "$parentBranch"