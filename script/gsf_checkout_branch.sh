#!/bin/bash

# Checks out the given branch and pulls the latest changes.

git checkout "$1"
git pull --prune