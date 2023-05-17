# init according to man page
if (( $+commands[rbenv] ))
then
  eval "$(rbenv init -)"
else
  if [ ! -z "$VERBOSE" ]
  then
    echo "rbenv not installed"
  fi
fi
