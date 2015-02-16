#/bin/bash

GITOLITE_SHELL=$HOME/bin/gitolite-shell

MYTTY=`tty`

if [ "$MYTTY" =  "not a tty" ]; then
  $GITOLITE_SHELL $@  
else
  echo "You are not allowed to run gitolite-shell from a terminal!"
fi
