# https://yarnpkg.com

if (( $+commands[yarn] ))
then
  export PATH="$PATH:`yarn global bin`"
else
  if [ ! -z "$VERBOSE" ]
  then
    echo "yarn not installed"
  fi
fi
