#!/bin/bash

# Checks whether there is already a release branch created
# Otherwise, it reads last app version
# Increments it according to the parameter
# Updates the file
# Creates a new release branch
# And commits the version_name.text
function create_new_release() {

    # Check if there is a branch that starts with "release"
    if git branch --list | grep -q "release"; then
        echo "ERROR: A release branch already exists. Please close it before creating a new version."
        echo "Exiting..."
        exit 0
    else
        echo "No release branch detected."
    fi

    currentBranch="$(git branch --show-current)"

    if [[ "$currentBranch" != "develop" ]]; then
        echo "ERROR: Releases must start from develop. Please checkout to develop branch first."
        echo "Exiting..."
        exit 0
    else
        echo "Current branch is develop."
    fi

    echo "Creating new release..."

    dir="$(dirname "${BASH_SOURCE[0]}")/get_version_name.sh"
    versionName="$(sh "$dir" | tr '.' ' ')"

    read -r major minor patch <<< "$versionName"

    echo "Old version $versionName"

    case "$1" in
        "M"|"maj"|"major") newVersion="$((major+1)).0.0";;
        "m"|"min"|"minor") newVersion="$major.$((minor+1)).0";;
        *) newVersion="$major.$minor.$((patch+1))";;
    esac

    echo "New release $newVersion"

    newReleaseBranch="release/$newVersion"

    git checkout -b "$newReleaseBranch"
    git config --add branch.develop.parent "$newReleaseBranch"
}

create_new_release "$1"
