# 0

Créer un fichier test.sh dans le dossier /srv/ avec le contenu suivant :

```
[Adryx@localhost /]$ sudo nano /srv/test.sh
[Adryx@localhost /]$ cat srv/test.sh
#!/bin/bash
#03/01/2023 - Adryan
#Simple test script

echo "Connecté actuellement avec l'utilisateur $(whoami)."
[Adryx@localhost /]$
```

Modifier les permissions du script test.sh :

```
[Adryx@localhost /]$ chmod x /srv/test.sh
chmod: invalid mode: ‘x’
Try 'chmod --help' for more information.
[Adryx@localhost /]$ chmod u+x /srv/test.sh
chmod: changing permissions of '/srv/test.sh': Operation not permitted
[Adryx@localhost /]$ sudo !!
sudo chmod u+x /srv/test.sh
[sudo] password for Adryx:
[Adryx@localhost /]$ nano /srv/test.sh
[Adryx@localhost /]$ ls -al /data
ls: cannot access '/data': No such file or directory
[Adryx@localhost /]$ ls -al /srv/
total 4
drwxr-xr-x.  2 root root  21 Jan  3 10:57 .
dr-xr-xr-x. 18 root root 235 Oct 13 11:03 ..
-rwxr--r--.  1 root root 114 Jan  3 10:59 test.sh
[Adryx@localhost /]$
```

Exécuter le script :
```
[Adryx@localhost /]$ /srv/test.sh
-bash: /srv/test.sh: Permission denied
[Adryx@localhost /]$ sudo !!
sudo /srv/test.sh
Connecté actuellement avec l'utilisateur root.
[Adryx@localhost /]$
```

# 2

```
[Adryx@localhost /]$ mkdir /srv/idcard
mkdir: cannot create directory ‘/srv/idcard’: Permission denied
[Adryx@localhost /]$ sudo !!
sudo mkdir /srv/idcard
[Adryx@localhost /]$
```

