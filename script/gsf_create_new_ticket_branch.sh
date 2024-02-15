#!/bin/bash

# Creates a new branch from the current branch with the following rules:
# develop -> task, feature, bugfix, supertask, release
# supertask -> task
# feature -> task, bugfix
# release -> bugfix
#
# Any other combination will exit with error.
#
# When te task is created, the parent branch is stored into the git config in order to be closed
# and checked out to the parent branch.
# git config --add "branch.$newBranch.parent" "$currentBranch"

to_branch() {
  local type="$1"
  local ticketId="${2:-}"
  local description="${3:-}"
  local author=$4
  
  local lower_description=$(echo "$description" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '_')

  local branch_parts=("$type" "$author" "${ticketId}_${lower_description}")
  if [ -z "$author" ]
  then
    unset 'branch_parts[1]'
  fi

  local output=$(printf '%s/' "${branch_parts[@]}" | awk NF)
  local outputWithoutLastSlash="${output:0:$((${#output} - 1))}"
  echo "$outputWithoutLastSlash"
}

get_new_branch() {
  local current_branch_type="$1"
  local current_branch_ticket_id="${2:-}"
  local current_branch_description="${3:-}"
  local new_branch_type="$4"
  local new_branch_ticket_id="${5:-}"
  local new_branch_description="${6:-}"
  local author="${7:-}"
  
  case "$new_branch_type" in
    task)
      case "$current_branch_type" in
        develop)
          to_branch task "$new_branch_ticket_id" "$new_branch_description" "$author"
          ;;
        feature)
          to_branch "$current_branch_description" "$new_branch_ticket_id" "$new_branch_description" "$author"
          ;;
        task)
          to_branch "$current_branch_ticket_id" "$new_branch_ticket_id" "$new_branch_description" "$author"
          ;;
        *)
          echo "$(tput setaf 1)ERROR: Forbidden new '$new_branch_type' from '$current_branch_type'$(tput setaf 0)" >&2
          exit 1
          ;;
      esac
      ;;
    bugfix)
      case "$current_branch_type" in
        develop|release)
          to_branch bugfix "$new_branch_ticket_id" "$new_branch_description" "$author"
          ;;
        feature)
          to_branch "$current_branch_ticket_id" "$new_branch_ticket_id" "$new_branch_description" "$author"
          ;;
        *)
          echo "$(tput setaf 1)ERROR: Forbidden new '$new_branch_type' from '$current_branch_type'$(tput setaf 0)" >&2
          exit 1
          ;;
      esac
      ;;
    release) # TODO: Special case, must be reviewed
      case "$current_branch_type" in
        develop)
          to_branch release "$new_branch_ticket_id" "$new_branch_description"
          ;;
        *)
          echo "$(tput setaf 1)ERROR: Forbidden new '$new_branch_type' from '$current_branch_type'$(tput setaf 0)" >&2
          exit 1
          ;;
      esac
      ;;
    feature)
      case "$current_branch_type" in
        develop)
          to_branch feature "$new_branch_ticket_id" "$new_branch_description"
          ;;
        *)
          echo "$(tput setaf 1)ERROR: Forbidden new '$new_branch_type' from '$current_branch_type'$(tput setaf 0)" >&2
          exit 1
          ;;
      esac
      ;;
    supertask)
      case "$current_branch_type" in
        develop)
          to_branch task "$new_branch_ticket_id" "$new_branch_description"
          ;;
        feature)
          to_branch "$current_branch_ticket_id" "$new_branch_ticket_id" "$new_branch_description"
          ;;
        *)
          echo "$(tput setaf 1)ERROR: Forbidden new '$new_branch_type' from '$current_branch_type'$(tput setaf 0)" >&2
          exit 1
          ;;
      esac
      ;;
    *)
      echo "$(tput setaf 1)ERROR: Forbidden command '$new_branch_type'" >&2
      exit 1
      ;;
  esac
}


newBranchType="$1"
newTicketId="$2"
newDescription="$3"

if [ -z "$newBranchType" ]
then
    echo "$(tput setaf 1)ERROR: First argument, branch type, is required (task, supertask, feature, bugfix)$(tput setaf 0)"
    exit 0
fi

if [ -z "$newTicketId" ]
then
    echo "$(tput setaf 1)ERROR: Second argument, ticket id, is required (AV-XXX)$(tput setaf 0)"
    exit 0
fi

if [ -z "$newDescription" ]
then
    echo "$(tput setaf 1)ERROR: Third argument, description, is required$(tput setaf 0)"
    exit 0
fi

currentBranch="$(git branch --show-current)"

IFS=/
read -ra parts <<< "$currentBranch"  

currentBranchType="${parts[0]}"
currentBranchTicket=${parts[${#parts[@]}-1]}
IFS=_ read -ra ticketParts <<< "$currentBranchTicket"

author=$(id -un)

currentBranchTicketId=${ticketParts[0]}
currentBranchDescription=${currentBranchTicket:$((${#currentBranchTicketId} +1 )):$((${#currentBranchTicket} - $((${#currentBranchTicketId} + 1))))}

newBranchType="$1"
newTicketId="$2"
newDescription="$3"

newBranch="$(get_new_branch "$currentBranchType" "$currentBranchTicketId" "$currentBranchDescription" "$newBranchType" "$newTicketId" "$newDescription" "$author")"

if [ -z "$newBranch" ]
then
    # An error occurred and has been already printed
    exit 0
fi

git checkout -b "$newBranch"
git config --add branch."$newBranch".parent "$currentBranch"