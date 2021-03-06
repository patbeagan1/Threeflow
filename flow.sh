#!/bin/sh

die() {
  echo "$1"
  exit 1
}

first="$1"
second="$2"

set -euf pipefail

DEVELOP="develop"
CANDIDATE="candidate"
MAIN="main"

BOLD="\e[1m"
ENDBOLD="\e[0m"

help() {
  OLD_IFS="$IFS"
  IFS=	
  echo $(
	cat <<HELPTEXT

Usage: flow (feature_start|feature_finish
            |patch_start|patch_finish
            |release_start|release_finish
            |hotfix_start|hotfix_finish) [branchname]

This script attempts to follow the cactus model / threeflow
https://www.nomachetejuggling.com/2017/04/09/a-different-branching-strategy/

$BOLD(init)$ENDBOLD
    Creates the original 3 branches: develop, candidate and main

$BOLD(v|view)$ENDBOLD
    Shows the current state of git, within the terminal.

$BOLD(fs|feature_start) [branchname]$ENDBOLD
    This will create the specified feature branch off of develop

$BOLD(ff|feature_finish [branchname]$ENDBOLD
    This will merge the specified feature branch back into develop

$BOLD(ps|patch_start) [branchname]$ENDBOLD
    This will create the specified patch branch off of candidate

$BOLD(pf|patch_finish) [branchname]$ENDBOLD
    This will merge the specified patch branch back into candidate

$BOLD(rs|release_start)$ENDBOLD
    This will start a new release by merging the develop branch into candidate.
    It will tag the place where it diverges from develop.

$BOLD(rf|release_finish)$ENDBOLD
    This will tag the release, and merge the candidate branch into 
	BOTH develop and main. 
    The merge to develop will be a --no-ff, and the merge to 
	main will be a fastforward.

$BOLD(hs|hotfix_start) [branchname]$ENDBOLD
    This will start a hotfix branch off of the main branch.
    It will tag the place where it diverges from main. 
    Since hotfix branches are temporary, they do not have a static name.

$BOLD(hf|hotfix_finish) [branchname]$ENDBOLD
    This will tag the hotfix, and merge it into main, candidate, and develop.

HELPTEXT
)
IFS=$OLD_IFS
}

##########
## Util
##########

header () {
  echo
  echo "################################"
}

footer () {
  echo "################################"
  echo
}

get_date() {
  date "+%y.%m.%d_%H.%M.%S"
}

checkoutPull () {
  header
  echo "# Locally updating branch: $1"
  footer
  git checkout "$1"
  git pull
  echo
}

warnPush () {
  header 
  echo "# Pushing branch to origin: $1"
  footer
  git push origin "$1"
  echo
}

merge() {
  checkoutPull "$1"
  header
  echo "# Merging $2 into $1"
  echo "# Type: merge commit" 
  footer
  git merge --no-ff "$2"
  warnPush "$1"
}

fastForwardMerge() {
  checkoutPull "$1"
  header
  echo "# Merging $2 into $1"
  echo "# Type: fastforward" 
  footer
  git merge --ff "$2"
  warnPush "$1"
}

autoMerge() {
  checkoutPull "$1"
  header
  echo "# Merging $2 into $1"
  echo "# Type: automatic merge commit" 
  footer
  git merge --no-ff --no-edit "$2"
  warnPush "$1"
}

ensureUpToDate() {
  checkoutPull "$1"
  warnPush "$1"
}

autoMergeIntegration() {
  integration_branch="$2_to_$1_v$3"
  checkoutPull "$1"
  git co -b "$integration_branch"
  git merge --no-edit "$2"
  git push origin "$integration_branch"
}

squashMerge() {
  if output=$(git status --porcelain) && [ -z "$output" ]; then
    checkoutPull "$1"
    git merge --squash "$2" && git commit
    warnPush "$1"
  else
    die "No action taken. There are uncommitted changes in the working directory."
  fi
}

tag() {
  git tag "$1"
  warnPush "$1"
}

cutFrom() {
  git checkout "$1"
  git checkout -b "$2"
}

initBranches() {
  git checkout -b $DEVELOP
  git checkout -b $CANDIDATE
  git checkout -b $MAIN
}

##########
## Feature
##########

featureCut() { cutFrom $DEVELOP "$1"; }
featureClose() {
  read -r -p "
  Warning: If you are on a multi-person team you should squash merge via github instead.
  If you're sure, press any key to continue.

  " REPLY
  squashMerge $DEVELOP "$1"
}

##########
## Patch
##########

patchCut() {  
  cutFrom $CANDIDATE "$1"
}

patchClose() { 
  squashMerge $CANDIDATE "$1" 
}

##########
## Release
##########

releaseCut() { 
  autoMerge $CANDIDATE $DEVELOP
}

releaseClose() {
  local_version="$1"
  changelog="$(git log --oneline candidate...main | cat)"

  ensureUpToDate $CANDIDATE
  fastForwardMerge $MAIN $CANDIDATE
  tag v"$local_version"

  header
  footer
  echo "# Changelog"
  echo
  echo '```'
  echo "$changelog"
  echo '```'
  header
  footer

  autoMergeIntegration $DEVELOP $CANDIDATE "$local_version"

}

##########
## Hotfix
##########

hotfixCut() {
  cutFrom $MAIN
  tag hotfix_start_"$(get_date)"
}

hotfixClose() {
  autoMerge $MAIN "$1"
  tag hotfix_"$(get_date)"
  read -r -p "Merge to main complete. Press any key to attempt a merge to candidate." REPLY
  autoMerge $CANDIDATE $MAIN
  read -r -p "Merge to candidate complete. Press any key to attempt a merge to develop." REPLY
  autoMerge $DEVELOP $MAIN
}

##########
## Main
##########

main() {
  if [ -z "$1" ]; then
    help
    exit 1
  fi
  
  git fetch

  case "$1" in
  "help")
    help
    ;;
  "init")
    initBranches
    ;;
  "feature_start" | "fs")
    if [ -z "$2" ]; then
      help
      die "Requires a branch name."
    fi
    featureCut "$2"
    ;;
  "feature_finish" | "ff")
    if [ -z "$2" ]; then
      help
      die "Requires a branch name."
    fi
    featureClose "$2"
    ;;
  "patch_start" | "ps")
    if [ -z "$2" ]; then
      help
      die "Requires a branch name."
    fi
    patchCut "$2"
    ;;
  "patch_finish" | "pf")
    if [ -z "$2" ]; then
      help
      die "Requires a branch name."
    fi
    patchClose "$2"
    ;;
  "release_start" | "rs")
    releaseCut
    ;;
  "release_finish" | "rf")
    if [ -z "$2" ]; then
      help
      die "Requires a semantic version."
    fi
    releaseClose "$2"
    ;;
  "hotfix_start" | "hs")
    if [ -z "$2" ]; then
      help
      die "Requires a branch name."
    fi
    hotfixCut "$2"
    ;;
  "hotfix_finish" | "hf")
    if [ -z "$2" ]; then
      help
      die "Requires a branch name."
    fi
    hotfixClose "$2"
    ;;
  "view" | "v")
    git log \
      --graph \
      --abbrev-commit \
      --decorate \
      --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' \
      --all
    ;;
  *)
    die "\"$1\" not recognized"
    ;;
  esac
}

main "$first" "$second"
