#!/bin/bash

# Reads the parent branch from the current branch stored into the git config.
# If the current branch is develop, release or main, it will exit with error.
# The parent was stored into the git config when the branch was created.
# git config --get "branch.$currentBranch.parent"
get_parent_ticket_branch() {
  local current_branch_type="$1"
  local currentBranch="$2"

  case "$current_branch_type" in
    develop|release|main)
        echo "$(tput setaf 1)ERROR: $current_branch_type branch cannot be closed like this" >&2
        exit 1
        ;;
    *)
        echo "$(git config --get "branch.$currentBranch.parent")"
        ;;
  esac
}

$(git pull --quiet --prune) >/dev/null

currentBranch="$(git branch --show-current)"

remoteBranch="$(git ls-remote origin "$currentBranch")"

if [ ! -z "$remoteBranch" ]
then 
    echo "$(tput setaf 1)ERROR: Remote for '$currentBranch' branch exists. Please merge into its parent and delete it first." >&2
    exit 0
fi

IFS=/
read -ra parts <<< "$currentBranch"  

currentBranchType="${parts[0]}"

parentBranch="$(get_parent_ticket_branch "$currentBranchType" "$currentBranch")"
echo "parent $parentBranch"

if [ -z "$parentBranch" ]
then
    exit 0
fi

# Store working copy
git stash
# Checkout to parent branch
git checkout "$parentBranch"
# Update all branches and prune remotes deleted
git pull --prune
# Delete child
git branch -d "$currentBranch"
# Restore working copy
git stash pop