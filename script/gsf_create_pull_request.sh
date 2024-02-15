#!/bin/bash

# Creates a pull request url from the current branch to the parent branch. Also opens the url in
# the browser.

load_configuration() {
  if [ -f .gitsuperflow/config.properties ]; then
    source .gitsuperflow/config.properties
  else
    source ~/.gitsuperflow/config.properties
  fi
}

get_parent_ticket_branch() {
  local current_branch_type="$1"
  local currentBranch="$2"
  local organisation="$3"
  local repo="$4"

  case "$current_branch_type" in
    develop|release|main)
        echo "$(tput setaf 1)ERROR: Cannot create a pull request from '$current_branch_type'" >&2
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

get_bitbucket_url() {
  local organisation="$1"
  local repo="$2"
  local title="$3"
  local currentBranch="$4"
  local parentBranch="${5:-develop}"

  echo "https://bitbucket.org/$organisation/$repo/pull-requests/new?source=$currentBranch&dest=$parentBranch&t=1&title=$title"
}

get_github_url() {
  local organisation="$1"
  local repo="$2"
  local title="$3"
  local currentBranch="$4"
  local parentBranch="${5:-develop}"

  echo "https://github.com/$organisation/$repo/compare/$parentBranch...$currentBranch?quick_pull=1title=$title"
}

load_configuration

git push -u origin "$currentBranch"

open "$(get_github_url "$organisation" "$repo" "tmp" "$currentBranch" "$parentBranch")"