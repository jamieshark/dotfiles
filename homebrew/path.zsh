if [[ "$(uname -s)" == "Darwin" ]] && (( $+commands[brew] )); then
  eval "$(brew shellenv)"
fi
