alias jjn='jj new'
function jjc() {
    for arg in "$@"; do
        if [ ! -e "$arg" ]; then
            echo "Error: Path '$arg' does not exist. Did you mean to use 'jjcm'?"
            return 1
        fi
    done
    jj commit "$@"
}
alias jjcm='jj commit -m'
alias jd='jj diff'
alias jjd='jj diff'
alias js='jj status'
alias jjsh='jj show'
alias jjpush='jj git push'
alias jjgp='jj git push'
alias jjgf='jj git fetch'
alias jjpb="jj log -r 'latest(heads(ancestors(@) & bookmarks()), 1)' --limit 1 --no-graph --ignore-working-copy -T local_bookmarks | tr -d '*'"
alias jjlf="jj log -rfull"
alias jjlt="jj lt"

function jj-push-tracked-confirm() {
  jj git push --tracked --dry-run || return

  printf "Push tracked bookmarks? [y/N] "
  read -r reply
  if [[ "$reply" == [Yy] ]]; then
    jj git push --tracked
  fi
}
alias jjgpt='jj-push-tracked-confirm'

alias copydiff="jj diff --from 'trunk()' | pbcopy"

function jj-track-bookmark-and-new() {
  jj git fetch -b $1 && jj bookmark track $1 && jj new $1
}
alias jjbtn="jj-track-bookmark-and-new"
alias jjbt="jj bookmark track"
alias jjblr="jj bookmark list --sort committer-date-"


function jj-fetch-and-new() {
  BRANCH=${1:-$(jjpb)}
  # Try to do "new" twice, occasionally we get concurrent checkout errors
  jj git fetch && (jj bookmark track $BRANCH || jj bookmark track $BRANCH) && (jj new $BRANCH || jj new $BRANCH)
}
alias jjfn=jj-fetch-and-new
alias jjfm='jj git fetch --branch main'

function jj-update-branch() {
  REV=${1:-@-}
  if [ $# -gt 0 ]; then
    shift
  fi

  BOOKMARK=$(jjpb)
  if [ "$BOOKMARK" = "production" ]; then
    echo "Can't jjub on production bookmark"
    return 1
  fi

  jj bookmark move $BOOKMARK --to "$REV" "$@"
}
alias jjub=jj-update-branch

function jj-merge-main() {
  BOOKMARK=${1:-$(jjpb)}
  if [ "$BOOKMARK" = "main" ]; then
    echo "Can not merge main into itself"
    return
  fi
  jj git fetch -b main && \
  jj new $BOOKMARK main && \
  jj b m $BOOKMARK -t@ && \
  jj commit -m 'merge main'
}

function jjbm() {
  BOOKMARK=$1
  REV=${2:-@-}
  shift 2

  jj bookmark move "$BOOKMARK" --to "$REV" "$@"
}

function jj-squash-into() {
  if [ $# -lt 1 ]; then
    echo "Usage: jj-squash-into <bookmark> [up-to]"
    return
  fi

  TO=${1}
  UP_TO=${2:-@}

  jj squash -t "${TO} & ancestors(${UP_TO})" -f "${TO}::${UP_TO}"
}
alias jjsi='jj-squash-into'

function jj-squash-after() {
  jj-squash-into $1+ $2
}
alias jjsa='jj-squash-after'

function jj-squash-branch() {
  REV=${1:-$(jjpb)}
  jj squash -f "branch($REV)" -t $REV
}
alias jjsb='jj-squash-branch'

function jj-squash-single-stack() {
  jj squash -f$1..$2 -t $2
}

alias jj-track-current='jj bookmark track $(jjpb)'
alias jjbtc='jj bookmark track $(jjpb)'

function jj-restack-from() {
  if [ $# -ne 1 ]; then
    echo "Usage: jj-restack-from <bookmark>"
    return
  fi
  BOOKMARK="stacked($1)"

  jj log -r "$BOOKMARK" -n50
  jj git fetch -b main && jj rebase -r "$BOOKMARK" -d main
}

function jj-rebase-merged-stack() {
  if [ $# -ne 1 ]; then
    echo "Usage: jj-rebase-merged-stack <bookmark>"
    return 1
  fi

  jj git fetch -b main || return

  REBASING_BOOKMARKS=$(jj log -r "$1+:: & bookmarks()" --no-graph --ignore-working-copy -T 'local_bookmarks ++ "\n"' | sed '/^$/d')
  if [ -n "$REBASING_BOOKMARKS" ]; then
    echo "Rebasing bookmarks:"
    echo "$REBASING_BOOKMARKS"
  else
    echo "No bookmarks found in rebase range."
  fi

  jj rebase -r "$1+::" -d main && \
    jj git fetch -b "$1"
}

alias jj-base-commit="jj log -r 'heads(::@ & ::main)' --no-graph -T 'commit_id'"

alias jjpc='jj git push --bookmark $(jjpb)'
