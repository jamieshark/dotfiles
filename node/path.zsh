if (( $+commands[npm] ))
then
  # Add npm bin
  export PATH=/usr/local/bin/npm:$PATH
else
  if [ ! -z "$VERBOSE" ]
  then
    echo "npm not installed"
  fi
fi
