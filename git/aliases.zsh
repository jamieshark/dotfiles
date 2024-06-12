# git
createBranchOffMain() {
  branch=$(git rev-parse --abbrev-ref origin)

  git checkout -b $1 $branch;
}

alias gcbm=createBranchOffMain
alias gs='git status'
alias gb='git branch'
alias gp='git push origin HEAD'
alias gcam='git commit -am'
