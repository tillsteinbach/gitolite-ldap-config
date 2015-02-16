#!/bin/bash

# author: till.steinbach@informatik.haw-hamburg.de

# Provides all ssh keys as user@ldapX.pub
#

LDAPSEARCH=/path/to/ldapsearch
GITOLITESHELL=/path/to/gitolite/src/gitolite-shell

ldap_keys() {
        user=$1;
        if [[ $user == git ]]; then
                $LDAPSEARCH -x -o ldif-wrap=no -LLL '(&(objectClass=inetOrgPerson)(sshPublicKey=*))' sshPublicKey | \
                while read line ;
                do      
                        if [ ! -z "$line" ]; then
                                if [[ $line == dn* ]]; then
                                        user=$(sed -n 's/.*uid=\([^,]*\).*/\1/p' <<< "$line")
                                        num_keys=0
                                elif [[ $line == sshPublicKey* ]]; then
                                        key=$(cut -d ":" -f 2 <<< "$line" | sed -e 's/^ *//' -e 's/ *$//')
                                        if [ ! -z "$key" ]; then
                                                if [[ $key != *$'\n'* ]] && [[ $key == ssh-* ]]; then
                                                        echo -n 'environment="USER='$user'",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty '
                                                        echo $key
                                                fi
                                                num_keys=$((num_keys+1))
                                        fi
                                fi
                        fi      
                done
                exit 0
        else
# this relies on openldap / pam_ldap to be configured properly on your
# system. my system allows anonymous search.
# Get all users with sshPublicKeys that are not in core-alumni group
                $LDAPSEARCH -x -o ldif-wrap=no -LLL '(&(&(objectClass=inetOrgPerson)(sshPublicKey=*)(uid='$user')))' sshPublicKey | \
                while read line ;
                do
                        if [ ! -z "$line" ]; then
                                if [[ $line == dn* ]]; then
                                        user=$(sed -n 's/.*uid=\([^,]*\).*/\1/p' <<< "$line")
                                        num_keys=0
                                elif [[ $line == sshPublicKey* ]]; then
                                        key=$(cut -d ":" -f 2 <<< "$line" | sed -e 's/^ *//' -e 's/ *$//')
                                        if [ ! -z "$key" ]; then
                                                if [[ $key != *$'\n'* ]] && [[ $key == ssh-* ]]; then
                                                        echo $key
                                                fi
                                                num_keys=$((num_keys+1))
                                        fi
                                fi
                        fi
                done
        fi
}    

ldap_keys $@
