&é

🌞 **Déterminez, pour ces 5 applications, si c'est du TCP ou de l'UDP**

```
Vidéo Youtube : 10.33.19.140 port:64483 -----> 35.186.224.25 port:443 UDP
Son Spotify : 10.33.19.140:49314 ------> 35.186.224.40 port:443 UDP
OneDrive : 10.33.19.140 port:50386 ------>  35.186.224.47 port:443 TCP
Téléchargement Steam : 10.33.19.140:64606 --------> 185.25.182.36:80 TCP
Discord appel : 10.33.19.140 port:53735 ------> 162.159.130.235 port:443 UDP 
```
🌞 **Demandez l'avis à votre OS**

- votre OS est responsable de l'ouverture des ports, et de placer un programme en "écoute" sur un port
- il est aussi responsable de l'ouverture d'un port quand une application demande à se connecter à distance vers un serveur
- bref il voit tout quoi
- utilisez la commande adaptée à votre OS pour repérer, dans la liste de toutes les connexions réseau établies, la connexion que vous voyez dans Wireshark, pour chacune des 5 applications

**Il faudra ajouter des options adaptées aux commandes pour y voir clair. Pour rappel, vous cherchez des connexions TCP ou UDP.**

```
# MacOS
$ netstat

# GNU/Linux
$ ss

# Windows
$ netstat
```

🦈🦈🦈🦈🦈 **Bah ouais, captures Wireshark à l'appui évidemment.** Une capture pour chaque application, qui met bien en évidence le trafic en question.

# II. Mise en place

## 1. SSH

🖥️ **Machine `node1.tp4.b1`**

- n'oubliez pas de dérouler la checklist (voir [les prérequis du TP](#0-prérequis))
- donnez lui l'adresse IP `10.4.1.11/24`

Connectez-vous en SSH à votre VM.
🌞 **Examinez le trafic dans Wireshark**

```
C'est du TCP
```

🌞 **Demandez aux OS**

- repérez, avec une commande adaptée (`netstat` ou `ss`), la connexion SSH depuis votre machine
- ET repérez la connexion SSH depuis votre VM
```
TCP    10.33.19.140:50630     35.186.224.47:443      ESTABLISHED
```

🦈 **Je veux une capture clean avec le 3-way handshake, un peu de trafic au milieu et une fin de connexion**

## 2. Routage

Ouais, un peu de répétition, ça fait jamais de mal. On va créer une machine qui sera notre routeur, et **permettra à toutes les autres machines du réseau d'avoir Internet.**

🖥️ **Machine `router.tp4.b1`**

- n'oubliez pas de dérouler la checklist (voir [les prérequis du TP](#0-prérequis))
- donnez lui l'adresse IP `10.4.1.254/24` sur sa carte host-only
- ajoutez-lui une carte NAT, qui permettra de donner Internet aux autres machines du réseau
- référez-vous au TP précédent

> Rien à remettre dans le compte-rendu pour cette partie.

# III. DNS

## 1. Présentation

Un serveur DNS est un serveur qui est capable de répondre à des requêtes DNS.

Une requête DNS est la requête effectuée par une machine lorsqu'elle souhaite connaître l'adresse IP d'une machine, lorsqu'elle connaît son nom.

Par exemple, si vous ouvrez un navigateur web et saisissez `https://www.google.com` alors une requête DNS est automatiquement effectuée par votre PC pour déterminez à quelle adresse IP correspond le nom `www.google.com`.

> La partie `https://` ne fait pas partie du nom de domaine, ça indique simplement au navigateur la méthode de connexion. Ici, c'est HTTPS.

Dans cette partie, on va monter une VM qui porte un serveur DNS. Ce dernier répondra aux autres VMs du LAN quand elles auront besoin de connaître des noms. Ainsi, ce serveur pourra :

- résoudre des noms locaux
  - vous pourrez `ping node1.tp4.b1` et ça fonctionnera
  - mais aussi `ping www.google.com` et votre serveur DNS sera capable de le résoudre aussi

*Dans la vraie vie, il n'est pas rare qu'une entreprise gère elle-même ses noms de domaine, voire gère elle-même son serveur DNS. C'est donc du savoir ré-utilisable pour tous qu'on voit ici.*

> En réalité, ce n'est pas votre serveur DNS qui pourra résoudre `www.google.com`, mais il sera capable de *forward* (faire passer) votre requête à un autre serveur DNS qui lui, connaît la réponse.

![Haiku DNS](./pics/haiku_dns.png)

## 2. Setup

🖥️ **Machine `dns-server.tp4.b1`**

- n'oubliez pas de dérouler la checklist (voir [les prérequis du TP](#0-prérequis))
- donnez lui l'adresse IP `10.4.1.201/24`

Installation du serveur DNS :

```bash
# assurez-vous que votre machine est à jour
$ sudo dnf update -y

# installation du serveur DNS, son p'tit nom c'est BIND9
$ sudo dnf install -y bind bind-utils
```

La configuration du serveur DNS va se faire dans 3 fichiers essentiellement :

- **un fichier de configuration principal**
  - `/etc/named.conf`
  - on définit les trucs généraux, comme les adresses IP et le port où on veu écouter
  - on définit aussi un chemin vers les autres fichiers, les fichiers de zone
- **un fichier de zone**
  - `/var/named/tp4.b1.db`
  - je vous préviens, la syntaxe fait mal
  - on peut y définir des correspondances `IP ---> nom`
- **un fichier de zone inverse**
  - `/var/named/tp4.b1.rev`
  - on peut y définir des correspondances `nom ---> IP`

➜ **Allooooons-y, fichier de conf principal**

```bash
# éditez le fichier de config principal pour qu'il ressemble à :
$ sudo cat /etc/named.conf
options {
        listen-on port 53 { 127.0.0.1; any; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
[...]
        allow-query     { localhost; any; };
        allow-query-cache { localhost; any; };

        recursion yes;
[...]
# référence vers notre fichier de zone
zone "tp4.b1" IN {
     type master;
     file "tp4.b1.db";
     allow-update { none; };
     allow-query {any; };
};
# référence vers notre fichier de zone inverse
zone "1.4.10.in-addr.arpa" IN {
     type master;
     file "tp4.b1.rev";
     allow-update { none; };
     allow-query { any; };
};
```

➜ **Et pour les fichiers de zone**

```bash
# Fichier de zone pour nom -> IP

$ sudo cat /var/named/tp4.b1.db

$TTL 86400
@ IN SOA dns-server.tp4.b1. admin.tp4.b1. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)

; Infos sur le serveur DNS lui même (NS = NameServer)
@ IN NS dns-server.tp4.b1.

; Enregistrements DNS pour faire correspondre des noms à des IPs
dns-server IN A 10.4.1.201
node1      IN A 10.4.1.11
```

```bash
# Fichier de zone inverse pour IP -> nom

$ sudo cat /var/named/tp4.b1.rev

$TTL 86400
@ IN SOA dns-server.tp4.b1. admin.tp4.b1. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)

; Infos sur le serveur DNS lui même (NS = NameServer)
@ IN NS dns-server.tp4.b1.

;Reverse lookup for Name Server
201 IN PTR dns-server.tp4.b1.
11 IN PTR node1.tp4.b1.
```

🌞 **Dans le rendu, je veux**

- un `cat` des fichiers de conf
- un `systemctl status named` qui prouve que le service tourne bien
- une commande `ss` qui prouve que le service écoute bien sur un port

🌞 **Ouvrez le bon port dans le firewall**

- grâce à la commande `ss` vous devrez avoir repéré sur quel port tourne le service
  - vous l'avez écrit dans la conf aussi toute façon :)
- ouvrez ce port dans le firewall de la machine `dns-server.tp4.b1` (voir le mémo réseau Rocky)

## 3. Test

🌞 **Sur la machine `node1.tp4.b1`**

- configurez la machine pour qu'elle utilise votre serveur DNS quand elle a besoin de résoudre des noms
- assurez vous que vous pouvez :
  - résoudre des noms comme `node1.tp4.b1` et `dns-server.tp4.b1`
  - mais aussi des noms comme `www.google.com`

🌞 **Sur votre PC**

- utilisez une commande pour résoudre le nom `node1.tp4.b1` en utilisant `10.4.1.201` comme serveur DNS

> Le fait que votre serveur DNS puisse résoudre un nom comme `www.google.com`, ça s'appelle la récursivité et c'est activé avec la ligne `recursion yes;` dans le fichier de conf.

🦈 **Capture d'une requête DNS vers le nom `node1.tp4.b1` ainsi que la réponse**🌞 **Dans le rendu, je veux**

- un `cat` des fichiers de conf

**Fichier de conf principal**
```
[Adryx@dns]$ sudo cat /etc/named.conf
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//
options {
        listen-on port 53 { 127.0.0.1; any; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        secroots-file   "/var/named/data/named.secroots";
        recursing-file  "/var/named/data/named.recursing";
        allow-query     { localhost; any; };
        allow-query-cache { localhost; any; };
        /*
         - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
         - If you are building a RECURSIVE (caching) DNS server, you need to enable
           recursion.
         - If your recursive DNS server has a public IP address, you MUST enable access
           control to limit queries to your legitimate users. Failing to do so will
           cause your server to become part of large scale DNS amplification
           attacks. Implementing BCP38 within your network would greatly
           reduce such attack surface
        */
        recursion yes;
        dnssec-validation yes;
        managed-keys-directory "/var/named/dynamic";
        geoip-directory "/usr/share/GeoIP";
        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
        /* https://fedoraproject.org/wiki/Changes/CryptoPolicy */
        include "/etc/crypto-policies/back-ends/bind.config";
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
zone "tp4.b1" IN {
     type master;
     file "tp4.b1.db";
     allow-update { none; };
     allow-query {any; };
};
zone "1.4.10.in-addr.arpa" IN {
     type master;
     file "tp4.b1.rev";
     allow-update { none; };
     allow-query { any; };
};
zone "." IN {
        type hint;
        file "named.ca";
};
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
```

**Et pour les fichiers de zone**

```bash
# Fichier de zone pour nom -> IP
$ sudo cat /var/named/tp4.b1.db
$TTL 86400
@ IN SOA dns-server.tp4.b1. admin.tp4.b1. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)
; Infos sur le serveur DNS lui même (NS = NameServer)
@ IN NS dns-server.tp4.b1.
; Enregistrements DNS pour faire correspondre des noms à des IPs
dns-server IN A 10.4.1.201
node1      IN A 10.4.1.11
```

```bash
# Fichier de zone inverse pour IP -> nom
$ sudo cat /var/named/tp4.b1.rev
$TTL 86400
@ IN SOA dns-server.tp4.b1. admin.tp4.b1. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)
; Infos sur le serveur DNS lui même (NS = NameServer)
@ IN NS dns-server.tp4.b1.
;Reverse lookup for Name Server
201 IN PTR dns-server.tp4.b1.
11 IN PTR node1.tp4.b1.
```
- un `systemctl status named` qui prouve que le service tourne bien
```
[Adryx@dns etc]$ systemctl status named
● named.service - Berkeley Internet Name Domain (DNS)
     Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; vendor>
     Active: active (running) since Tue 2022-11-01 20:51:01 CET; 48min ago
   Main PID: 704 (named)
      Tasks: 5 (limit: 2684)
     Memory: 29.6M
        CPU: 216ms
     CGroup: /system.slice/named.service
             └─704 /usr/sbin/named -u named -c /etc/named.conf
```
- une commande `ss` qui prouve que le service écoute bien sur un port
```
[Adryx@dns etc]$ ss -lnt
State             Recv-Q            Send-Q                       Local Address:Port                         Peer Address:Port            Process
LISTEN            0                 10                              10.4.1.201:53                                0.0.0.0:*
```

🌞 **Ouvrez le bon port dans le firewall**

- grâce à la commande `ss` vous devrez avoir repéré sur quel port tourne le service
```
port : 53
```
- ouvrez ce port dans le firewall de la machine `dns-server.tp4.b1` (voir le mémo réseau Rocky)
```
[Adryx@dns etc]$ sudo firewall-cmd --add-port=53/tcp --permanent
success
[Adryx@dns etc]$ sudo firewall-cmd --reload
success
```
## 3. Test

🌞 **Sur la machine `node1.tp4.b1`**

- configurez la machine pour qu'elle utilise votre serveur DNS quand elle a besoin de résoudre des noms
```
[Adryx@node1 network-scripts]$ cat /etc/resolv.conf
# Generated by NetworkManager
nameserver 10.4.1.201
```
- assurez vous que vous pouvez :
  - résoudre des noms comme `node1.tp4.b1` et `dns-server.tp4.b1`
```
[Adryx@node1 ~]$ dig node1.tp4.b1
; <<>> DiG 9.16.23-RH <<>> node1.tp4.b1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 46124
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 63d7d4e4ca6b2eb701000000636230bc3684a7d6d00f5f99 (good)
;; QUESTION SECTION:
;node1.tp4.b1.                  IN      A
;; ANSWER SECTION:
node1.tp4.b1.           86400   IN      A       10.4.1.11
;; Query time: 1 msec
;; SERVER: 10.4.1.201#53(10.4.1.201)
;; WHEN: Wed Nov 02 09:56:28 CET 2022
;; MSG SIZE  rcvd: 85
```
```
[Adryx@node1 ~]$ dig dns-server.tp4.b1
; <<>> DiG 9.16.23-RH <<>> dns-server.tp4.b1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 32167
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: e7688d1b5de248c6010000006362311c24f7fa06250e0082 (good)
;; QUESTION SECTION:
;dns-server.tp4.b1.             IN      A
;; ANSWER SECTION:
dns-server.tp4.b1.      86400   IN      A       10.4.1.201
;; Query time: 1 msec
;; SERVER: 10.4.1.201#53(10.4.1.201)
;; WHEN: Wed Nov 02 09:58:04 CET 2022
;; MSG SIZE  rcvd: 90
```
  - mais aussi des noms comme `www.google.com`
```
[Adryx@node1 ~]$ dig www.google.com
; <<>> DiG 9.16.23-RH <<>> www.google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 49839
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 0e42732e2fe376a501000000636230945fd22ee8a5d5c896 (good)
;; QUESTION SECTION:
;www.google.com.                        IN      A
;; ANSWER SECTION:
www.google.com.         300     IN      A       142.250.201.164
;; Query time: 461 msec
;; SERVER: 10.4.1.201#53(10.4.1.201)
;; WHEN: Wed Nov 02 09:55:48 CET 2022
;; MSG SIZE  rcvd: 87
```

🌞 **Sur votre PC**

- utilisez une commande pour résoudre le nom `node1.tp4.b1` en utilisant `10.4.1.201` comme serveur DNS
```
PS C:\Windows\system32> Get-DnsClientServerAddress
InterfaceAlias               Interface Address ServerAddresses
                             Index     Family
--------------               --------- ------- ---------------
Wi-Fi                                7 IPv4    {192.168.2.1}
Wi-Fi                                7 IPv6    {}
```
```
PS C:\Windows\system32> netsh interface ipv4 add dnsserver "Wi-Fi" 10.4.1.201 index=7
```
```
PS C:\Windows\system32> ipconfig /all
Carte réseau sans fil Wi-Fi :
   Suffixe DNS propre à la connexion. . . : home
   Description. . . . . . . . . . . . . . : Intel(R) Wi-Fi 6 AX201 160MHz
   Adresse physique . . . . . . . . . . . : F2-9B-85-D2-57-A9
   DHCP activé. . . . . . . . . . . . . . : Oui
   Adresse IPv6. . . . . . . . . . . . . .: 2a01:cb19:8f4:6c00:d478:f3cd:3e0f:b798(préféré)
   Adresse IPv6 temporaire . . . . . . . .: 2a01:cb19:8f4:6c00:865:df38:6bf4:81b6(préféré)
   Adresse IPv6 de liaison locale. . . . .: fe80::d478:f3cd:3e0f:b798%7(préféré)
   Adresse IPv4. . . . . . . . . . . . . .: 192.168.2.17(préféré)
   Masque de sous-réseau. . . . . . . . . : 255.255.255.0
   Bail obtenu. . . . . . . . . . . . . . : mercredi 2 novembre 2022 10:29:58
   Bail expirant. . . . . . . . . . . . . : jeudi 3 novembre 2022 10:48:51
   Passerelle par défaut. . . . . . . . . : fe80::8ef8:13ff:fe2f:234e%7
                                       192.168.2.1
   Serveur DHCP . . . . . . . . . . . . . : 192.168.2.1
   IAID DHCPv6 . . . . . . . . . . . : 133340037
   DUID de client DHCPv6. . . . . . . . : 00-03-00-01-F2-9B-85-D2-57-A9
   Serveurs DNS. . .  . . . . . . . . . . : 10.4.1.201
                                       2a01:cb19:8f4:6c00:8ef8:13ff:fe2f:234e
   NetBIOS sur Tcpip. . . . . . . . . . . : Activé
   Liste de recherche de suffixes DNS propres à la connexion :
                                       home
```
```
PS C:\Windows\system32> nslookup
Serveur par dÚfaut :   dns-server.tp4.b1
Address:  10.4.1.201
> node1.tp4.b1
Serveur :   dns-server.tp4.b1
Address:  10.4.1.201
Nom :    node1.tp4.b1
Address:  10.4.1.11
```

IMPORTANT == Un pote m'as aidé pour le faire j'ai galéré Voila et les screen c'est l'est sienne 

🦈 **Capture d'une requête DNS vers le nom `node1.tp4.b1` ainsi que la réponse**