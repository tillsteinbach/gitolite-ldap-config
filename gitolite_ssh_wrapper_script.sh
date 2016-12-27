#!/bin/bash
#HOME and PATH are only exported when gitolite-shell is called
HOME_ORIG=$HOME
HOME=/path/to/gitolite
PATH=$PATH:/path/to/git/bin/
GITOLITE_SHELL=$HOME/bin/gitolite-shell

#Commands that are forwarded to gitolite-shell
declare -a gitolitecommands=("D" "create" "desc" "help" "info" "mirror" "perms" "writable" "git*")

for gitolitecommand in "${gitolitecommands[@]}"
do
        if [ -n "$SSH_ORIGINAL_COMMAND" ]; then
                #if original command was one of the specified gitolitecommands run shell as user git with parameter user
                #$USER was either set by SSHD or in the environment="USER=username" statement of the ldap_authorized_keys.sh 
                if [[ "$SSH_ORIGINAL_COMMAND" == ${gitolitecommand}* ]]; then
                        #export paths to run the shell (sudo -E forwards these!)
                        export HOME
                        export PATH
                        sudo -E --user=git $GITOLITE_SHELL $USER
                        exit 0
                fi
        fi
done
#if you don't want to allow shell access uncomment the next line!
#exit 0
# Never run shell when user is user git!
if [[ $(id) == $(id git) ]]; then
        echo "git is not allowed to have a shell! try help command!"
        exit 0
fi

# Restore HOME variable back
HOME=$HOME_ORIG
export HOME

# Might be a command? If it is a command execute shell with -c
if [ -n "$SSH_ORIGINAL_COMMAND" ]; then
        $SHELL -c "$SSH_ORIGINAL_COMMAND"
        exit 0
fi
# Fallback: run the users shell instead
$SHELL
