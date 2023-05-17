
if (( $+commands[python] ))
then
  # Add python
  export PATH=/usr/local/bin/python:$PATH
else
  if [ ! -z "$VERBOSE" ]
  then
    echo "Python not installed"
  fi
fi
