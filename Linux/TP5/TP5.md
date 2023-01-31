# Partie 1

🌞 Installer le serveur Apache

```
 [Adryx@Web ~]$ sudo dnf install -y httpd
```

```
[Adryx@Web ~]$ cat /etc/httpd/conf/httpd.conf

ServerRoot "/etc/httpd"

Listen 80

Include conf.modules.d/*.conf

User apache
Group apache


ServerAdmin root@localhost


<Directory />
    AllowOverride none
    Require all denied
</Directory>


DocumentRoot "/var/www/html"

<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>

<Directory "/var/www/html">
    Options Indexes FollowSymLinks

    AllowOverride None

    Require all granted
</Directory>

<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>

<Files ".ht*">
    Require all denied
</Files>

ErrorLog "logs/error_log"

LogLevel warn

<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common

    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>


    CustomLog "logs/access_log" combined
</IfModule>

<IfModule alias_module>


    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"

</IfModule>

<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>

<IfModule mime_module>
    TypesConfig /etc/mime.types

    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz



    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>

AddDefaultCharset UTF-8

<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>


EnableSendfile on

IncludeOptional conf.d/*.conf
[Adryx@Web ~]$
```

🌞 Démarrer le service Apache

```
[Adryx@Web ~]$ sudo systemctl start httpd
[Adryx@Web ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-01-31 09:42:12 CET; 10min ago
       Docs: man:httpd.service(8)
   Main PID: 737 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec"
      Tasks: 213 (limit: 5904)
     Memory: 34.3M
        CPU: 516ms
     CGroup: /system.slice/httpd.service
             ├─737 /usr/sbin/httpd -DFOREGROUND
             ├─756 /usr/sbin/httpd -DFOREGROUND
             ├─758 /usr/sbin/httpd -DFOREGROUND
             ├─759 /usr/sbin/httpd -DFOREGROUND
             └─760 /usr/sbin/httpd -DFOREGROUND

Jan 31 09:42:12 Web systemd[1]: Starting The Apache HTTP Server...
Jan 31 09:42:12 Web httpd[737]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, >
Jan 31 09:42:12 Web systemd[1]: Started The Apache HTTP Server.
Jan 31 09:42:12 Web httpd[737]: Server configured, listening on: port 80
```
```
[Adryx@Web ~]$ sudo systemctl enable httpd
[sudo] password for Adryx:
Sorry, try again.
[sudo] password for Adryx:
[Adryx@Web ~]$

sudo firewall-cmd --zone=public --add-port=80/tcp
success

[Adryx@Web ~]$ ss -lp | grep httpd
u_str LISTEN 0      100                    /etc/httpd/run/cgisock.737 19580

```
🌞 TEST

```
[Adryx@Web ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-01-31 10:29:05 CET; 22min ago
       Docs: man:httpd.service(8)
   Main PID: 727 (httpd)
     Status: "Total requests: 3; Idle/Busy workers 100/0;Requests/sec: 0.0022; Bytes served/sec:  17 B/sec"
      Tasks: 213 (limit: 5904)
     Memory: 32.6M
        CPU: 865ms
     CGroup: /system.slice/httpd.service
             ├─727 /usr/sbin/httpd -DFOREGROUND
             ├─758 /usr/sbin/httpd -DFOREGROUND
             ├─759 /usr/sbin/httpd -DFOREGROUND
             ├─760 /usr/sbin/httpd -DFOREGROUND
             └─762 /usr/sbin/httpd -DFOREGROUND

Jan 31 10:29:04 Web systemd[1]: Starting The Apache HTTP Server...
Jan 31 10:29:05 Web httpd[727]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, >
Jan 31 10:29:05 Web httpd[727]: Server configured, listening on: port 80
Jan 31 10:29:05 Web systemd[1]: Started The Apache HTTP Server.
```
```
[Adryx@Web ~]$ sudo systemctl is-enabled httpd
enabled
[Adryx@Web ~]$
```
```
// pour verif le site grâce a Curl Il faut regardé le fichier du dossier 'curl.TEST'
```

🌞 Le service Apache...

```
 sudo systemctl cat httpd
[sudo] password for Adryx:
# /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
```

🌞 Déterminer sous quel utilisateur tourne le processus Apache

```
[Adryx@Web ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep User
User apache <-----
```

```
grep httpd
root         727       1  0 10:29 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       758     727  0 10:29 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       759     727  0 10:29 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       760     727  0 10:29 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       762     727  0 10:29 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1266     727  0 11:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
Adryx       1467    1416  0 11:29 pts/0    00:00:00 grep --color=auto httpd
[Adryx@Web ~]$
```

```
ls -al
total 12
drwxr-xr-x.  2 root root   24 Jan 17 12:12 .
drwxr-xr-x. 82 root root 4096 Jan 17 12:12 ..
-rw-r--r--.  1 root root 7620 Jan 31 11:33 index.html
[Adryx@Web testpage]$
```

🌞 Changer l’utilisateur utilisé par Apache

```
[Adryx@Web ~]$ useradd ApacheAdryan -d /usr/share/httpd -s /sbin/nologin -u 80
useradd: Permission denied.
useradd: cannot lock /etc/passwd; try again later.
[Adryx@Web ~]$ sudo !!
sudo useradd ApacheAdryan -d /usr/share/httpd -s /sbin/nologin -u 80
[sudo] password for Adryx:
useradd warning: ApacheAdryan's uid 80 outside of the UID_MIN 1000 and UID_MAX 60000 range.
useradd: warning: the home directory /usr/share/httpd already exists.
useradd: Not copying any file from skel directory into it.
```
```
[Adryx@Web ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep User
User ApacheAdryan
```

```
[Adryx@Web ~]$ sudo systemctl stop httpd
[sudo] password for Adryx:
[Adryx@Web ~]$ sudo systemctl start httpd
[Adryx@Web ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-01-31 11:55:09 CET; 9s ago
       Docs: man:httpd.service(8)
   Main PID: 1091 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec"
      Tasks: 213 (limit: 5904)
     Memory: 24.8M
        CPU: 50ms
     CGroup: /system.slice/httpd.service
             ├─1091 /usr/sbin/httpd -DFOREGROUND
             ├─1092 /usr/sbin/httpd -DFOREGROUND
             ├─1093 /usr/sbin/httpd -DFOREGROUND
             ├─1094 /usr/sbin/httpd -DFOREGROUND
             └─1095 /usr/sbin/httpd -DFOREGROUND

Jan 31 11:55:08 Web systemd[1]: Starting The Apache HTTP Server...
Jan 31 11:55:08 Web httpd[1091]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name,>
Jan 31 11:55:09 Web systemd[1]: Started The Apache HTTP Server.
Jan 31 11:55:09 Web httpd[1091]: Server configured, listening on: port 80
[Adryx@Web ~]$ ps -ef | grep httpd
root        1091       1  0 11:55 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
ApacheA+    1092    1091  0 11:55 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
ApacheA+    1093    1091  0 11:55 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
ApacheA+    1094    1091  0 11:55 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
ApacheA+    1095    1091  0 11:55 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
Adryx       1315    1060  0 11:56 pts/0    00:00:00 grep --color=auto httpd
```

🌞 Faites en sorte que Apache tourne sur un autre port

```
[Adryx@Web ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep Listen
Listen 111
[Adryx@Web ~]$ sudo firewall-cmd --zone=public --permanent --add-port 111/tcp
success
[Adryx@Web ~]$ sudo firewall-cmd --reload
success
[Adryx@Web ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client http https ssh
  ports: 111/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[Adryx@Web ~]$ sudo systemctl reboot
[sudo] password for Adryx:
[Adryx@Web ~]$ Connection to 10.105.1.11 closed by remote host.
Connection to 10.105.1.11 closed.
PS C:\Users\happy cash> ssh Adryx@10.105.1.11
Adryx@10.105.1.11's password:
Last login: Tue Jan 31 11:53:36 2023 from 10.105.1.1
[Adryx@Web ~]$ sudo ss -alpnt | grep httpd
LISTEN 0      511                *:111             *:*    users:(("httpd",pid=763,fd=4),("httpd",pid=762,fd=4),("httpd",pid=761,fd=4),("httpd",pid=738,fd=4))
[Adryx@Web ~]$
```
Partie 2 : Mise en place et maîtrise du serveur de base de données

🌞 Install de MariaDB sur db.tp5.linux

```
[Adryx@DB ~]$ sudo dnf install mariadb-server
..
..
..
..
Complete !

[Adryx@DB ~]$ sudo mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] yes
Enabled successfully!
Reloading privilege tables..
 ... Success!


You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n] y
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n]
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n]
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
[Adryx@DB ~]$
[Adryx@DB ~]$ sudo systemstl enable mariadb
sudo: systemstl: command not found
[Adryx@DB ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
[Adryx@DB ~]$ sudo systemctl status mariadb
○ mariadb.service - MariaDB 10.5 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; vendor preset: disabled)
     Active: inactive (dead)
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
[Adryx@DB ~]$ sudo systemctl restart mariadb
[Adryx@DB ~]$ sudo systemctl status mariadb
● mariadb.service - MariaDB 10.5 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-01-31 15:13:55 CET; 6s ago
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
    Process: 12791 ExecStartPre=/usr/libexec/mariadb-check-socket (code=exited, status=0/SUCCESS)
    Process: 12813 ExecStartPre=/usr/libexec/mariadb-prepare-db-dir mariadb.service (code=exited, status=0/SUCCESS)
    Process: 12911 ExecStartPost=/usr/libexec/mariadb-check-upgrade (code=exited, status=0/SUCCESS)
   Main PID: 12896 (mariadbd)
     Status: "Taking your SQL requests now..."
      Tasks: 14 (limit: 5904)
     Memory: 75.0M
        CPU: 296ms
     CGroup: /system.slice/mariadb.service
             └─12896 /usr/libexec/mariadbd --basedir=/usr

Jan 31 15:13:55 DB mariadb-prepare-db-dir[12852]: you need to be the system 'mysql' user to connect.
Jan 31 15:13:55 DB mariadb-prepare-db-dir[12852]: After connecting you can set the password, if you would need to be
Jan 31 15:13:55 DB mariadb-prepare-db-dir[12852]: able to connect as any of these users with a password and without sudo
Jan 31 15:13:55 DB mariadb-prepare-db-dir[12852]: See the MariaDB Knowledgebase at https://mariadb.com/kb
Jan 31 15:13:55 DB mariadb-prepare-db-dir[12852]: Please report any problems at https://mariadb.org/jira
Jan 31 15:13:55 DB mariadb-prepare-db-dir[12852]: The latest information about MariaDB is available at https://mariadb.>
Jan 31 15:13:55 DB mariadb-prepare-db-dir[12852]: Consider joining MariaDB's strong and vibrant community:
Jan 31 15:13:55 DB mariadb-prepare-db-dir[12852]: https://mariadb.org/get-involved/
Jan 31 15:13:55 DB mariadbd[12896]: 2023-01-31 15:13:55 0 [Note] /usr/libexec/mariadbd (mysqld 10.5.16-MariaDB) startin>
Jan 31 15:13:55 DB systemd[1]: Started MariaDB 10.5 database server.
```

🌞 Port utilisé par MariaDB

```
 sudo ss -alnpt | grep maria
LISTEN 0      80                 *:3306            *:*    users:(("mariadbd",pid=12896,fd=19))
[Adryx@DB ~]$

[Adryx@DB ~]$ sudo firewall-cmd --zone=public --permanent --add-port 3306/tcp
Warning: ALREADY_ENABLED: 3306:tcp
success
[Adryx@DB ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[Adryx@DB ~]$ sudo firewall-cmd --reload
success
[Adryx@DB ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 3306/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

```
[Adryx@DB ~]$ ps -ef | grep maria
mysql      12896       1  0 15:13 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
Adryx      13263     930  0 15:39 pts/0    00:00:00 grep --color=auto maria
```

🌞 Préparation de la base pour NextCloud

```
[Adryx@DB ~]$ sudo mysql -u root -p
[sudo] password for Adryx:
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 39
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.11' IDENTIDIED BY 'pewpewpew';
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'IDENTIDIED BY 'pewpewpew'' at line 1
MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.11' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.003 sec)

MariaDB [(none)]>
MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11';
Query OK, 0 rows affected (0.003 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]>
```

🌞 Exploration de la base de données

```
[Adryx@Web ~]$ mysql -u nextcloud -h 10.105.1.12 -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 54
Server version: 5.5.5-10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)

mysql> USE nextcloud
Database changed
mysql> SHOW TABLES;
Empty set (0.00 sec)

mysql>
```

🌞 Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données

```
MariaDB [(none)]> select user,host from mysql.user;
+-------------+-------------+
| User        | Host        |
+-------------+-------------+
| nextcloud   | 10.105.1.11 |
| mariadb.sys | localhost   |
| mysql       | localhost   |
| root        | localhost   |
+-------------+-------------+
4 rows in set (0.002 sec)
```

🌞 Installer de PHP

``` 
[Adryx@Web ~]$ sudo dnf config-manager --set-enabled crb
[sudo] password for Adryx:
[Adryx@Web ~]$ sudo dnf config-manager --set-enabled crb
[Adryx@Web ~]$ sudo systemctl status config-manager
Unit config-manager.service could not be found.
[Adryx@Web ~]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
Rocky Linux 9 - BaseOS                                                                  6.3 kB/s | 3.6 kB     00:00
Rocky Linux 9 - AppStream                                                               9.4 kB/s | 4.1 kB     00:00
Rocky Linux 9 - CRB                                                                     1.1 MB/s | 2.0 MB     00:01
remi-release-9.rpm                                                                      246 kB/s |  28 kB     00:00
Dependencies resolved.
========================================================================================================================
 Package                               Architecture        Version                      Repository                 Size
========================================================================================================================
Installing:
 remi-release                          noarch              9.1-2.el9.remi               @commandline               28 k
 yum-utils                             noarch              4.1.0-3.el9                  baseos                     36 k
Upgrading:
 dnf                                   noarch              4.12.0-4.el9                 baseos                    451 k
 dnf-data                              noarch              4.12.0-4.el9                 baseos                     39 k
 dnf-plugins-core                      noarch              4.1.0-3.el9                  baseos                     33 k
 libdnf                                x86_64              0.67.0-3.el9                 baseos                    654 k
 libsolv                               x86_64              0.7.22-1.el9                 baseos                    392 k
 python3-dnf                           noarch              4.12.0-4.el9                 baseos                    409 k
 python3-dnf-plugins-core              noarch              4.1.0-3.el9                  baseos                    221 k
 python3-hawkey                        x86_64              0.67.0-3.el9                 baseos                    105 k
 python3-libdnf                        x86_64              0.67.0-3.el9                 baseos                    774 k
 rocky-release                         noarch              9.1-1.11.el9                 baseos                     22 k
 rocky-repos                           noarch              9.1-1.11.el9                 baseos                     12 k
 yum                                   noarch              4.12.0-4.el9                 baseos                     91 k
Installing dependencies:
 epel-release                          noarch              9-4.el9                      extras                     19 k

Transaction Summary
========================================================================================================================
Install   3 Packages
Upgrade  12 Packages

Total size: 3.2 M
Total download size: 3.2 M
Downloading Packages:
(1/14): epel-release-9-4.el9.noarch.rpm                                                  98 kB/s |  19 kB     00:00
(2/14): yum-utils-4.1.0-3.el9.noarch.rpm                                                121 kB/s |  36 kB     00:00
(3/14): yum-4.12.0-4.el9.noarch.rpm                                                     291 kB/s |  91 kB     00:00
(4/14): dnf-data-4.12.0-4.el9.noarch.rpm                                                732 kB/s |  39 kB     00:00
(5/14): python3-dnf-plugins-core-4.1.0-3.el9.noarch.rpm                                 459 kB/s | 221 kB     00:00
(6/14): dnf-4.12.0-4.el9.noarch.rpm                                                     712 kB/s | 451 kB     00:00
(7/14): dnf-plugins-core-4.1.0-3.el9.noarch.rpm                                         225 kB/s |  33 kB     00:00
(8/14): rocky-release-9.1-1.11.el9.noarch.rpm                                           478 kB/s |  22 kB     00:00
(9/14): rocky-repos-9.1-1.11.el9.noarch.rpm                                             372 kB/s |  12 kB     00:00
(10/14): libsolv-0.7.22-1.el9.x86_64.rpm                                                610 kB/s | 392 kB     00:00
(11/14): python3-dnf-4.12.0-4.el9.noarch.rpm                                            257 kB/s | 409 kB     00:01
(12/14): python3-hawkey-0.67.0-3.el9.x86_64.rpm                                         501 kB/s | 105 kB     00:00
(13/14): python3-libdnf-0.67.0-3.el9.x86_64.rpm                                         634 kB/s | 774 kB     00:01
(14/14): libdnf-0.67.0-3.el9.x86_64.rpm                                                 553 kB/s | 654 kB     00:01
------------------------------------------------------------------------------------------------------------------------
Total                                                                                   915 kB/s | 3.2 MB     00:03
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                1/1
  Upgrading        : rocky-repos-9.1-1.11.el9.noarch                                                               1/27
  Upgrading        : rocky-release-9.1-1.11.el9.noarch                                                             2/27
  Upgrading        : libsolv-0.7.22-1.el9.x86_64                                                                   3/27
  Upgrading        : libdnf-0.67.0-3.el9.x86_64                                                                    4/27
  Upgrading        : python3-libdnf-0.67.0-3.el9.x86_64                                                            5/27
  Upgrading        : python3-hawkey-0.67.0-3.el9.x86_64                                                            6/27
  Upgrading        : dnf-data-4.12.0-4.el9.noarch                                                                  7/27
  Upgrading        : python3-dnf-4.12.0-4.el9.noarch                                                               8/27
  Upgrading        : dnf-4.12.0-4.el9.noarch                                                                       9/27
  Running scriptlet: dnf-4.12.0-4.el9.noarch                                                                       9/27
  Upgrading        : python3-dnf-plugins-core-4.1.0-3.el9.noarch                                                  10/27
  Upgrading        : dnf-plugins-core-4.1.0-3.el9.noarch                                                          11/27
  Installing       : epel-release-9-4.el9.noarch                                                                  12/27
  Running scriptlet: epel-release-9-4.el9.noarch                                                                  12/27
Many EPEL packages require the CodeReady Builder (CRB) repository.
It is recommended that you run /usr/bin/crb enable to enable the CRB repository.

  Installing       : remi-release-9.1-2.el9.remi.noarch                                                           13/27
  Installing       : yum-utils-4.1.0-3.el9.noarch                                                                 14/27
  Upgrading        : yum-4.12.0-4.el9.noarch                                                                      15/27
  Cleanup          : rocky-release-9.0-2.3.el9.noarch                                                             16/27
  Cleanup          : dnf-plugins-core-4.0.24-4.el9_0.noarch                                                       17/27
  Cleanup          : python3-dnf-plugins-core-4.0.24-4.el9_0.noarch                                               18/27
  Cleanup          : yum-4.10.0-5.el9_0.noarch                                                                    19/27
  Running scriptlet: dnf-4.10.0-5.el9_0.noarch                                                                    20/27
  Cleanup          : dnf-4.10.0-5.el9_0.noarch                                                                    20/27
  Running scriptlet: dnf-4.10.0-5.el9_0.noarch                                                                    20/27
  Cleanup          : python3-dnf-4.10.0-5.el9_0.noarch                                                            21/27
  Cleanup          : dnf-data-4.10.0-5.el9_0.noarch                                                               22/27
  Cleanup          : rocky-repos-9.0-2.3.el9.noarch                                                               23/27
  Cleanup          : python3-hawkey-0.65.0-5.1.el9.x86_64                                                         24/27
  Cleanup          : python3-libdnf-0.65.0-5.1.el9.x86_64                                                         25/27
  Cleanup          : libdnf-0.65.0-5.1.el9.x86_64                                                                 26/27
  Cleanup          : libsolv-0.7.20-2.el9.x86_64                                                                  27/27
  Running scriptlet: libsolv-0.7.20-2.el9.x86_64                                                                  27/27
  Verifying        : yum-utils-4.1.0-3.el9.noarch                                                                  1/27
  Verifying        : epel-release-9-4.el9.noarch                                                                   2/27
  Verifying        : remi-release-9.1-2.el9.remi.noarch                                                            3/27
  Verifying        : yum-4.12.0-4.el9.noarch                                                                       4/27
  Verifying        : yum-4.10.0-5.el9_0.noarch                                                                     5/27
  Verifying        : python3-dnf-4.12.0-4.el9.noarch                                                               6/27
  Verifying        : python3-dnf-4.10.0-5.el9_0.noarch                                                             7/27
  Verifying        : dnf-data-4.12.0-4.el9.noarch                                                                  8/27
  Verifying        : dnf-data-4.10.0-5.el9_0.noarch                                                                9/27
  Verifying        : dnf-4.12.0-4.el9.noarch                                                                      10/27
  Verifying        : dnf-4.10.0-5.el9_0.noarch                                                                    11/27
  Verifying        : python3-dnf-plugins-core-4.1.0-3.el9.noarch                                                  12/27
  Verifying        : python3-dnf-plugins-core-4.0.24-4.el9_0.noarch                                               13/27
  Verifying        : dnf-plugins-core-4.1.0-3.el9.noarch                                                          14/27
  Verifying        : dnf-plugins-core-4.0.24-4.el9_0.noarch                                                       15/27
  Verifying        : rocky-release-9.1-1.11.el9.noarch                                                            16/27
  Verifying        : rocky-release-9.0-2.3.el9.noarch                                                             17/27
  Verifying        : rocky-repos-9.1-1.11.el9.noarch                                                              18/27
  Verifying        : rocky-repos-9.0-2.3.el9.noarch                                                               19/27
  Verifying        : libsolv-0.7.22-1.el9.x86_64                                                                  20/27
  Verifying        : libsolv-0.7.20-2.el9.x86_64                                                                  21/27
  Verifying        : python3-libdnf-0.67.0-3.el9.x86_64                                                           22/27
  Verifying        : python3-libdnf-0.65.0-5.1.el9.x86_64                                                         23/27
  Verifying        : python3-hawkey-0.67.0-3.el9.x86_64                                                           24/27
  Verifying        : python3-hawkey-0.65.0-5.1.el9.x86_64                                                         25/27
  Verifying        : libdnf-0.67.0-3.el9.x86_64                                                                   26/27
  Verifying        : libdnf-0.65.0-5.1.el9.x86_64                                                                 27/27

Upgraded:
  dnf-4.12.0-4.el9.noarch                      dnf-data-4.12.0-4.el9.noarch        dnf-plugins-core-4.1.0-3.el9.noarch
  libdnf-0.67.0-3.el9.x86_64                   libsolv-0.7.22-1.el9.x86_64         python3-dnf-4.12.0-4.el9.noarch
  python3-dnf-plugins-core-4.1.0-3.el9.noarch  python3-hawkey-0.67.0-3.el9.x86_64  python3-libdnf-0.67.0-3.el9.x86_64
  rocky-release-9.1-1.11.el9.noarch            rocky-repos-9.1-1.11.el9.noarch     yum-4.12.0-4.el9.noarch
Installed:
  epel-release-9-4.el9.noarch          remi-release-9.1-2.el9.remi.noarch          yum-utils-4.1.0-3.el9.noarch

Complete!
[Adryx@Web ~]$ dnf module list php
Extra Packages for Enterprise Linux 9 - x86_64                                          1.3 MB/s |  13 MB     00:10
Remi's Modular repository for Enterprise Linux 9 - x86_64                               2.9 kB/s | 833  B     00:00
Remi's Modular repository for Enterprise Linux 9 - x86_64                               3.0 MB/s | 3.1 kB     00:00
Importing GPG key 0x478F8947:
 Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
 Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
Is this ok [y/N]: yes
Remi's Modular repository for Enterprise Linux 9 - x86_64                               1.1 MB/s | 838 kB     00:00
Safe Remi's RPM repository for Enterprise Linux 9 - x86_64                              4.1 kB/s | 833  B     00:00
Safe Remi's RPM repository for Enterprise Linux 9 - x86_64                              3.0 MB/s | 3.1 kB     00:00
Importing GPG key 0x478F8947:
 Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
 Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
Is this ok [y/N]: yes
Safe Remi's RPM repository for Enterprise Linux 9 - x86_64                              1.1 MB/s | 890 kB     00:00
Rocky Linux 9 - BaseOS                                                                  1.0 MB/s | 1.7 MB     00:01
Rocky Linux 9 - AppStream                                                               1.3 MB/s | 6.4 MB     00:04
Rocky Linux 9 - CRB                                                                     1.0 MB/s | 2.0 MB     00:02
Rocky Linux 9 - Extras                                                                   16 kB/s | 8.5 kB     00:00
Rocky Linux 9 - AppStream
Name                Stream                 Profiles                                 Summary
php                 8.1                    common [d], devel, minimal               PHP scripting language

Remi's Modular repository for Enterprise Linux 9 - x86_64
Name                Stream                 Profiles                                 Summary
php                 remi-7.4               common [d], devel, minimal               PHP scripting language
php                 remi-8.0               common [d], devel, minimal               PHP scripting language
php                 remi-8.1               common [d], devel, minimal               PHP scripting language
php                 remi-8.2               common [d], devel, minimal               PHP scripting language

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
[Adryx@Web ~]$ sudo dnf module enable php:remi-8.1 -y
Extra Packages for Enterprise Linux 9 - x86_64                                          1.3 MB/s |  13 MB     00:10
Remi's Modular repository for Enterprise Linux 9 - x86_64                               3.7 kB/s | 833  B     00:00
Remi's Modular repository for Enterprise Linux 9 - x86_64                               3.0 MB/s | 3.1 kB     00:00
Importing GPG key 0x478F8947:
 Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
 Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
Remi's Modular repository for Enterprise Linux 9 - x86_64                               1.1 MB/s | 838 kB     00:00
Safe Remi's RPM repository for Enterprise Linux 9 - x86_64                              4.4 kB/s | 833  B     00:00
Safe Remi's RPM repository for Enterprise Linux 9 - x86_64                              3.0 MB/s | 3.1 kB     00:00
Importing GPG key 0x478F8947:
 Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
 Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
Safe Remi's RPM repository for Enterprise Linux 9 - x86_64                              1.1 MB/s | 890 kB     00:00
Dependencies resolved.
========================================================================================================================
 Package                     Architecture               Version                       Repository                   Size
========================================================================================================================
Enabling module streams:
 php                                                    remi-8.1

Transaction Summary
========================================================================================================================

Complete!
[Adryx@Web ~]$ sudo dnf install -y php81-php
Last metadata expiration check: 0:00:10 ago on Tue 31 Jan 2023 17:04:36 CET.
Dependencies resolved.
========================================================================================================================
 Package                           Architecture         Version                           Repository               Size
========================================================================================================================
Installing:
 php81-php                         x86_64               8.1.14-1.el9.remi                 remi-safe               1.7 M
Installing dependencies:
 environment-modules               x86_64               5.0.1-1.el9                       baseos                  481 k
 libsodium                         x86_64               1.0.18-8.el9                      epel                    161 k
 libxslt                           x86_64               1.1.34-9.el9                      appstream               240 k
 oniguruma5php                     x86_64               6.9.8-1.el9.remi                  remi-safe               219 k
 php81-php-common                  x86_64               8.1.14-1.el9.remi                 remi-safe               667 k
 php81-runtime                     x86_64               8.1-2.el9.remi                    remi-safe               1.1 M
 scl-utils                         x86_64               1:2.0.3-2.el9                     appstream                37 k
 tcl                               x86_64               1:8.6.10-7.el9                    baseos                  1.1 M
Installing weak dependencies:
 php81-php-cli                     x86_64               8.1.14-1.el9.remi                 remi-safe               3.5 M
 php81-php-fpm                     x86_64               8.1.14-1.el9.remi                 remi-safe               1.8 M
 php81-php-mbstring                x86_64               8.1.14-1.el9.remi                 remi-safe               475 k
 php81-php-opcache                 x86_64               8.1.14-1.el9.remi                 remi-safe               378 k
 php81-php-pdo                     x86_64               8.1.14-1.el9.remi                 remi-safe                86 k
 php81-php-sodium                  x86_64               8.1.14-1.el9.remi                 remi-safe                41 k
 php81-php-xml                     x86_64               8.1.14-1.el9.remi                 remi-safe               141 k

Transaction Summary
========================================================================================================================
Install  16 Packages

Total download size: 12 M
Installed size: 49 M
Downloading Packages:
(1/16): libsodium-1.0.18-8.el9.x86_64.rpm                                               461 kB/s | 161 kB     00:00
(2/16): oniguruma5php-6.9.8-1.el9.remi.x86_64.rpm                                       452 kB/s | 219 kB     00:00
(3/16): php81-php-common-8.1.14-1.el9.remi.x86_64.rpm                                   479 kB/s | 667 kB     00:01
(4/16): php81-php-8.1.14-1.el9.remi.x86_64.rpm                                          462 kB/s | 1.7 MB     00:03
(5/16): php81-php-mbstring-8.1.14-1.el9.remi.x86_64.rpm                                 683 kB/s | 475 kB     00:00
(6/16): php81-php-opcache-8.1.14-1.el9.remi.x86_64.rpm                                  608 kB/s | 378 kB     00:00
(7/16): php81-php-pdo-8.1.14-1.el9.remi.x86_64.rpm                                      563 kB/s |  86 kB     00:00
(8/16): php81-php-sodium-8.1.14-1.el9.remi.x86_64.rpm                                   721 kB/s |  41 kB     00:00
(9/16): php81-php-xml-8.1.14-1.el9.remi.x86_64.rpm                                      669 kB/s | 141 kB     00:00
(10/16): php81-php-fpm-8.1.14-1.el9.remi.x86_64.rpm                                     341 kB/s | 1.8 MB     00:05
(11/16): php81-runtime-8.1-2.el9.remi.x86_64.rpm                                        671 kB/s | 1.1 MB     00:01
(12/16): php81-php-cli-8.1.14-1.el9.remi.x86_64.rpm                                     507 kB/s | 3.5 MB     00:07
(13/16): environment-modules-5.0.1-1.el9.x86_64.rpm                                     629 kB/s | 481 kB     00:00
(14/16): scl-utils-2.0.3-2.el9.x86_64.rpm                                               258 kB/s |  37 kB     00:00
(15/16): libxslt-1.1.34-9.el9.x86_64.rpm                                                293 kB/s | 240 kB     00:00
(16/16): tcl-8.6.10-7.el9.x86_64.rpm                                                    775 kB/s | 1.1 MB     00:01
------------------------------------------------------------------------------------------------------------------------
Total                                                                                   1.2 MB/s |  12 MB     00:09
Extra Packages for Enterprise Linux 9 - x86_64                                          580 kB/s | 1.6 kB     00:00
Importing GPG key 0x3228467C:
 Userid     : "Fedora (epel9) <epel@fedoraproject.org>"
 Fingerprint: FF8A D134 4597 106E CE81 3B91 8A38 72BF 3228 467C
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9
Key imported successfully
Safe Remi's RPM repository for Enterprise Linux 9 - x86_64                              3.0 MB/s | 3.1 kB     00:00
Importing GPG key 0x478F8947:
 Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
 Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                1/1
  Installing       : libxslt-1.1.34-9.el9.x86_64                                                                   1/16
  Installing       : tcl-1:8.6.10-7.el9.x86_64                                                                     2/16
  Installing       : environment-modules-5.0.1-1.el9.x86_64                                                        3/16
  Running scriptlet: environment-modules-5.0.1-1.el9.x86_64                                                        3/16
  Installing       : scl-utils-1:2.0.3-2.el9.x86_64                                                                4/16
  Installing       : php81-runtime-8.1-2.el9.remi.x86_64                                                           5/16
  Running scriptlet: php81-runtime-8.1-2.el9.remi.x86_64                                                           5/16
  Installing       : php81-php-common-8.1.14-1.el9.remi.x86_64                                                     6/16
  Installing       : php81-php-cli-8.1.14-1.el9.remi.x86_64                                                        7/16
  Installing       : php81-php-fpm-8.1.14-1.el9.remi.x86_64                                                        8/16
  Running scriptlet: php81-php-fpm-8.1.14-1.el9.remi.x86_64                                                        8/16
  Installing       : php81-php-opcache-8.1.14-1.el9.remi.x86_64                                                    9/16
  Installing       : php81-php-pdo-8.1.14-1.el9.remi.x86_64                                                       10/16
  Installing       : php81-php-xml-8.1.14-1.el9.remi.x86_64                                                       11/16
  Installing       : oniguruma5php-6.9.8-1.el9.remi.x86_64                                                        12/16
  Installing       : php81-php-mbstring-8.1.14-1.el9.remi.x86_64                                                  13/16
  Installing       : libsodium-1.0.18-8.el9.x86_64                                                                14/16
  Installing       : php81-php-sodium-8.1.14-1.el9.remi.x86_64                                                    15/16
  Installing       : php81-php-8.1.14-1.el9.remi.x86_64                                                           16/16
  Running scriptlet: php81-php-8.1.14-1.el9.remi.x86_64                                                           16/16
  Verifying        : libsodium-1.0.18-8.el9.x86_64                                                                 1/16
  Verifying        : oniguruma5php-6.9.8-1.el9.remi.x86_64                                                         2/16
  Verifying        : php81-php-8.1.14-1.el9.remi.x86_64                                                            3/16
  Verifying        : php81-php-cli-8.1.14-1.el9.remi.x86_64                                                        4/16
  Verifying        : php81-php-common-8.1.14-1.el9.remi.x86_64                                                     5/16
  Verifying        : php81-php-fpm-8.1.14-1.el9.remi.x86_64                                                        6/16
  Verifying        : php81-php-mbstring-8.1.14-1.el9.remi.x86_64                                                   7/16
  Verifying        : php81-php-opcache-8.1.14-1.el9.remi.x86_64                                                    8/16
  Verifying        : php81-php-pdo-8.1.14-1.el9.remi.x86_64                                                        9/16
  Verifying        : php81-php-sodium-8.1.14-1.el9.remi.x86_64                                                    10/16
  Verifying        : php81-php-xml-8.1.14-1.el9.remi.x86_64                                                       11/16
  Verifying        : php81-runtime-8.1-2.el9.remi.x86_64                                                          12/16
  Verifying        : environment-modules-5.0.1-1.el9.x86_64                                                       13/16
  Verifying        : tcl-1:8.6.10-7.el9.x86_64                                                                    14/16
  Verifying        : libxslt-1.1.34-9.el9.x86_64                                                                  15/16
  Verifying        : scl-utils-1:2.0.3-2.el9.x86_64                                                               16/16

Installed:
  environment-modules-5.0.1-1.el9.x86_64                      libsodium-1.0.18-8.el9.x86_64
  libxslt-1.1.34-9.el9.x86_64                                 oniguruma5php-6.9.8-1.el9.remi.x86_64
  php81-php-8.1.14-1.el9.remi.x86_64                          php81-php-cli-8.1.14-1.el9.remi.x86_64
  php81-php-common-8.1.14-1.el9.remi.x86_64                   php81-php-fpm-8.1.14-1.el9.remi.x86_64
  php81-php-mbstring-8.1.14-1.el9.remi.x86_64                 php81-php-opcache-8.1.14-1.el9.remi.x86_64
  php81-php-pdo-8.1.14-1.el9.remi.x86_64                      php81-php-sodium-8.1.14-1.el9.remi.x86_64
  php81-php-xml-8.1.14-1.el9.remi.x86_64                      php81-runtime-8.1-2.el9.remi.x86_64
  scl-utils-1:2.0.3-2.el9.x86_64                              tcl-1:8.6.10-7.el9.x86_64

Complete!
[Adryx@Web ~]$
```

🌞 Install de tous les modules PHP nécessaires pour NextCloud

```
[Adryx@Web ~]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
```

🌞 Récupérer NextCloud

```
j'ai instlé NextCloud sur mon PC a moi pouis je les SCP copy (c'est la seul facon que j'ai trouvé sans utilisé Curl car j'ai pas tout compris x)

PS C:\Users\happy cash> scp nextcloud.zip Adryx@10.105.1.11:/home/Adryx
Adryx@10.105.1.11's password:
nextcloud.zip                                                                         100%  168MB  93.8MB/s   00:01
PS C:\Users\happy cash>

[Adryx@Web ~]$ ls /home/Adryx/
d  nextcloud.zip
[Adryx@Web ~]$ dnf provides unzip
Last metadata expiration check: 0:32:31 ago on Tue 31 Jan 2023 17:04:15 CET.
unzip-6.0-56.el9.x86_64 : A utility for unpacking zip files
Repo        : baseos
Matched from:
Provide    : unzip = 6.0-56.el9

[Adryx@Web ~]$ sudo dnf install unzip
[sudo] password for Adryx:
Last metadata expiration check: 0:32:26 ago on Tue 31 Jan 2023 17:04:36 CET.
Dependencies resolved.
========================================================================================================================
 Package                   Architecture               Version                          Repository                  Size
========================================================================================================================
Installing:
 unzip                     x86_64                     6.0-56.el9                       baseos                     180 k

Transaction Summary
========================================================================================================================
Install  1 Package

Total download size: 180 k
Installed size: 392 k
Is this ok [y/N]: y
Downloading Packages:
unzip-6.0-56.el9.x86_64.rpm                                                             845 kB/s | 180 kB     00:00
------------------------------------------------------------------------------------------------------------------------
Total                                                                                   338 kB/s | 180 kB     00:00
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                1/1
  Installing       : unzip-6.0-56.el9.x86_64                                                                        1/1
  Running scriptlet: unzip-6.0-56.el9.x86_64                                                                        1/1
  Verifying        : unzip-6.0-56.el9.x86_64                                                                        1/1

Installed:
  unzip-6.0-56.el9.x86_64

Complete!
[Adryx@Web ~]$ unzip nextcloud
..
..
..
..
[Adryx@Web ~]$ ls
d  nextcloud  nextcloud.zip
[Adryx@Web ~]$ cp nextcloud /var/www/tp5_nextcloud/
cp: -r not specified; omitting directory 'nextcloud'
[Adryx@Web ~]$ cp nextcloud /var/www/tp5_nextcloud/ -r
cp: cannot create directory '/var/www/tp5_nextcloud/nextcloud': Permission denied
[Adryx@Web ~]$ cp nextcloud /var/www/tp5_nextcloud
cp: -r not specified; omitting directory 'nextcloud'
[Adryx@Web ~]$ sudo nextcloud /var/www/
cgi-bin/       html/          tp5_nextcloud/
[Adryx@Web ~]$ sudo nextcloud /var/www/tp5_nextcloud/
sudo: nextcloud: command not found
[Adryx@Web ~]$ sudo cp nextcloud /var/www/tp5_nextcloud/
cp: -r not specified; omitting directory 'nextcloud'
[Adryx@Web ~]$ sudo cp nextcloud /var/www/tp5_nextcloud/ -r
[Adryx@Web ~]$ cd /var/www/tp5_nextcloud/nextcloud
[Adryx@Web tp5_nextcloud]$ cd nextcloud/
[Adryx@Web nextcloud]$ ls
3rdparty  config       core      index.html  occ           ocs-provider  resources   themes
apps      console.php  cron.php  index.php   ocm-provider  public.php    robots.txt  updater
AUTHORS   COPYING      dist      lib         ocs           remote.php    status.php  version.php
[Adryx@Web ~]$[Adryx@Web nextcloud]$ mv * cd ..
mv: cannot move '3rdparty' to '../3rdparty': Permission denied
mv: cannot move 'apps' to '../apps': Permission denied
mv: cannot move 'AUTHORS' to '../AUTHORS': Permission denied
mv: cannot move 'config' to '../config': Permission denied
mv: cannot move 'console.php' to '../console.php': Permission denied
mv: cannot move 'COPYING' to '../COPYING': Permission denied
mv: cannot move 'core' to '../core': Permission denied
mv: cannot move 'cron.php' to '../cron.php': Permission denied
mv: cannot move 'dist' to '../dist': Permission denied
mv: cannot move 'index.html' to '../index.html': Permission denied
mv: cannot move 'index.php' to '../index.php': Permission denied
mv: cannot move 'lib' to '../lib': Permission denied
mv: cannot move 'occ' to '../occ': Permission denied
mv: cannot move 'ocm-provider' to '../ocm-provider': Permission denied
mv: cannot move 'ocs' to '../ocs': Permission denied
mv: cannot move 'ocs-provider' to '../ocs-provider': Permission denied
mv: cannot move 'public.php' to '../public.php': Permission denied
mv: cannot move 'remote.php' to '../remote.php': Permission denied
mv: cannot move 'resources' to '../resources': Permission denied
mv: cannot move 'robots.txt' to '../robots.txt': Permission denied
mv: cannot move 'status.php' to '../status.php': Permission denied
mv: cannot move 'themes' to '../themes': Permission denied
mv: cannot move 'updater' to '../updater': Permission denied
mv: cannot move 'version.php' to '../version.php': Permission denied
mv: cannot stat 'cd': No such file or directory
[Adryx@Web nextcloud]$ sudo !!
sudo mv * cd ..
[sudo] password for Adryx:
mv: cannot stat 'cd': No such file or directory
[Adryx@Web nextcloud]$ ls
[Adryx@Web nextcloud]$ cd ..
[Adryx@Web tp5_nextcloud]$ ls
3rdparty  config       core      index.html  nextcloud     ocs           remote.php  status.php  version.php
apps      console.php  cron.php  index.php   occ           ocs-provider  resources   themes
AUTHORS   COPYING      dist      lib         ocm-provider  public.php    robots.txt  updater
[Adryx@Web tp5_nextcloud]$ sudo rm nextcloud/
rm: cannot remove 'nextcloud/': Is a directory
[Adryx@Web tp5_nextcloud]$ sudo rm nextcloud/ -r
[Adryx@Web tp5_nextcloud]$ ls
3rdparty  config       core      index.html  occ           ocs-provider  resources   themes
apps      console.php  cron.php  index.php   ocm-provider  public.php    robots.txt  updater
AUTHORS   COPYING      dist      lib         ocs           remote.php    status.php  version.php
[Adryx@Web www]$ sudo chown apache tp5_nextcloud/
[sudo] password for Adryx:
[Adryx@Web www]$ ls -al
total 8
drwxr-xr-x.  5 root   root   54 Jan 31 17:25 .
drwxr-xr-x. 20 root   root 4096 Jan 17 12:12 ..
drwxr-xr-x.  2 root   root    6 Nov 16 08:11 cgi-bin
drwxr-xr-x.  2 root   root    6 Nov 16 08:11 html
drwxr-xr-x. 14 apache root 4096 Jan 31 17:51 tp5_nextcloud
[Adryx@Web www]$
```







