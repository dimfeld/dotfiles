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

alias copydiff="jj diff --from 'trunk()' | pbcopy"

function jj-track-bookmark-and-new() {
  jj bookmark track $1 && jj new $1
}
alias jjbtn="jj-track-bookmark-and-new"
alias jjbt="jj bookmark track"
alias jjblr="jj bookmark list --sort committer-date-"

function jj-fetch-and-new() {
  BRANCH=${1:-$(jjpb)}
  # Try to do "new" twice, occasionally we get concurrent checkout errors
  jj git fetch && (jj new $BRANCH || jj new $BRANCH)
}
alias jjfn=jj-fetch-and-new
alias jjfm='jj git fetch --branch main'

function jj-update-branch() {
  REV=${1:-@-}
  if [ $# -gt 0 ]; then
    shift
  fi
  jj bookmark move $(jjpb) --to "$REV" "$@"
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

  jj squash -t ${TO} -f "${TO}..${UP_TO}"
}
alias jjsi='jj-squash-into'

function jj-squash-after() {
  jj-squash-into $1+ $2
}

alias jj-squash-branch='jj squash -f "branch($(jjpb))" -t $(jjpb)'
alias jjsb='jj-squash-branch'

alias jj-track-current='jj bookmark track $(jjpb)'
alias jjtc='jj bookmark track $(jjpb)'

function jj-restack-from() {
  if [ $# -ne 1 ]; then
    echo "Usage: jj-restack-from <bookmark>"
    return
  fi
  BOOKMARK="stacked($1)"

  jj log -r "$BOOKMARK" -n50
  jj git fetch -b main && jj rebase -r "$BOOKMARK" -d main
}

function jj-rebase-main() {
  jj git fetch -b main && jj rebase -d main
}


