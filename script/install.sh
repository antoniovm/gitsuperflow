#!/bin/bash

# Adds the following aliases to the git config --global:
#
# git develop
# git main
# git release <release_level>
# git task <ticket_id> <description> <author>
# git bugfix <ticket_id> <description> <author>
# git feature <ticket_id> <description> <author>
# git supertask <ticket_id> <description> <author>
# git close
# git pr

# Home dir
user_home_dir="~"
gsf_dir="$user_home_dir/.gitsuperflow"

# Clone repo into ~/.gitsuperflow if it doesn't exist
if [ ! -d "$gsf_dir" ]; 
then
  echo "Cloning gitsuperflow into $gsf_dir"
  # git clone 
fi

echo "Installing gitsuperflow aliases..."

git config --global alias.develop '!sh '"$gsf_dir"'/script/gsf_checkout_branch.sh develop'
git config --global alias.main '!sh '"$gsf_dir"'/script/gsf_checkout_branch.sh main'
git config --global alias.release '!sh '"$gsf_dir"'/script/gsf_create_new_release.sh "$1"'
git config --global alias.task '!sh '"$gsf_dir"'/script/gsf_create_new_ticket_branch.sh task "$1" "$2"'
git config --global alias.bugfix '!sh '"$gsf_dir"'/script/gsf_create_new_ticket_branch.sh bugfix "$1" "$2"'
git config --global alias.feature '!sh '"$gsf_dir"'/script/gsf_create_new_ticket_branch.sh feature "$1" "$2"'
git config --global alias.supertask '!sh '"$gsf_dir"'/script/gsf_create_new_ticket_branch.sh supertask "$1" "$2"'
git config --global alias.close '!sh '"$gsf_dir"'/script/gsf_close_ticket_branch.sh'
git config --global alias.pr '!sh '"$gsf_dir"'/script/gsf_create_pull_request.sh'
git config --global alias.align '!sh '"$gsf_dir"'/script/gsf_align_branch_with_parent.sh'



echo "Git Superflow aliases added to git config --global"