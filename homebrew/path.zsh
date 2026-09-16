for brew_command in \
  "${commands[brew]:-}" \
  /opt/homebrew/bin/brew \
  /usr/local/bin/brew \
  /home/linuxbrew/.linuxbrew/bin/brew
do
  if [[ -n "$brew_command" && -x "$brew_command" ]]; then
    eval "$("$brew_command" shellenv)"
    break
  fi
done

unset brew_command
