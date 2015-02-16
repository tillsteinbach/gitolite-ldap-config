#!/bin/bash
#HOME and PATH are only exported when gitolite-shell is called
HOME=/path/to/gitolite
PATH=$PATH:/prog/git/bin/
GITOLITE_SHELL=$HOME/bin/gitolite-shell
SUDO=/opt/csw/bin/sudo
export GITOLITE_HTTP_HOME="/path/to/gitolite"
export GIT_PROJECT_ROOT="/path/to/gitolite/repositories"

export GIT_HTTP_EXPORT_ALL=1

if [ -z "$AUTHENTICATE_UID" ]; then
        export REMOTE_USER=anonymous
else
        export REMOTE_USER=$AUTHENTICATE_UID
fi

$SUDO -E --user=git $GITOLITE_SHELL $REMOTE_USER

#env
