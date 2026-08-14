# https://yarnpkg.com

if (( $+commands[yarn] )); then
  yarn_bin="$(yarn global bin 2>/dev/null)" || yarn_bin=
  [[ -d "$yarn_bin" ]] && path+=("$yarn_bin")
  unset yarn_bin
elif [[ -n "$VERBOSE" ]]; then
  echo "yarn not installed"
fi
