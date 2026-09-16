# Keep PATH entries unique while preserving their first occurrence.
typeset -gU path PATH

for path_dir in \
  /usr/local/sbin \
  /usr/local/bin \
  /opt/homebrew/sbin \
  /opt/homebrew/bin \
  "$ZSH/bin" \
  "$HOME/bin"
do
  [[ -d "$path_dir" ]] && path=("$path_dir" $path)
done

unset path_dir
export PATH
