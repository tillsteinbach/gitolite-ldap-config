# gitolite-ldap-config
Run gitolite with LDAP backend and SSH + HTTP/S

The scripts allow to use "git clone git@server:somerepo" syntax with pubkey only, "git clone username@server:somerepo" with pubky and password via ssh, or "git clone http://server/publicrepo" as user anonymous and "git clone https://server/somerepo" with username and password.

There might be several ways to connect gitolite with ldap. This is ours! If you find a way to do it better, send me a patch!
I don't show how to configure LDAP. This howto expects that you have some knowledge about ssh/apache2/LDAP.

* Requirements:
    * sudo
    * openssh
    * apache
    * Running LDAP Server

## Prerequisite
### SUDO
* Allow all users to execute gitolite-shell under user git:
```
ALL ALL=(git) NOPASSWD:SETENV: /path/to/gitolite/bin/gitolite-shell 
```
**Warning!** This is a security problem if the user has access to the system running gitolite (most cases). We did not come up with a better solution yet.

### SSH
* Is your system already is configured to use LDAP? Fine! Go on. If not find one of the thousands of howtos for your system.
* If you would like to use SSH-Keys as well you can add the ldap_authorized_keys.sh script and these lines for openssh to the sshd_config:
```
AuthorizedKeysCommand /path/to/script/ldap_authorized_keys.sh
AuthorizedKeysCommandUser nobody
```
## Wrapper Scripts

### SSH
* Now lets forward requests to gitolite.
* Let your sshd execute the wrapper script:
```
PermitUserEnvironment yes
ForceCommand /path/to/gitolite_ssh_wrapper_script.sh
```

### HTTP/S
* We want to let users access public repositories anonymously using http. And force users to log in using https
**Warning!** with this configuration @all containes the anonymous user!
* Add gitolite_http_wrapper_script.sh
* Configure apache virtual host for anonymous access via http:
```
<VirtualHost your.domain:80>
        ScriptAlias / /path/to/gitolite_http_wrapper_script/

        <Location />
                Allow from all
        </Location>
</VirtualHost>
```
* Configure apache virtual host for ldap login access via https:
```
<VirtualHost your.domain:443>
        SSLEngine On
        SSLCertificateFile "etc/apache2/server.crt"
        SSLCertificateKeyFile "/etc/apache2/server.key"
        ScriptAlias / /path/to/gitolite_http_wrapper_script/

        <Location />
                Options FollowSymLinks
                AllowOverride None
                Order Allow,Deny
                Allow from all
                AuthType Basic
                AuthBasicProvider ldap
                AuthLDAPUrl ldap://127.0.0.1/ou=people,dc=example?uid?sub
                AuthLDAPBindAuthoritative Off
                AuthLDAPGroupAttribute memberUid
                AuthLDAPGroupAttributeIsDN Off
                AuthName "LDAP Login"
                #require ldap-group cn=core-admin,ou=groups,dc=example
                require valid-user
        </Location>
</VirtualHost>
```
