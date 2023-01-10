# TP3 : On va router des trucs

Au menu de ce TP, on va revoir un peu ARP et IP histoire de **se mettre en jambes dans un environnement avec des VMs**.

Puis on mettra en place **un routage simple, pour permettre à deux LANs de communiquer**.

![Reboot the router](./pics/reboot.jpeg)

## Sommaire

- [TP3 : On va router des trucs](#tp3--on-va-router-des-trucs)
  - [Sommaire](#sommaire)
  - [0. Prérequis](#0-prérequis)
  - [I. ARP](#i-arp)
    - [1. Echange ARP](#1-echange-arp)
    - [2. Analyse de trames](#2-analyse-de-trames)
  - [II. Routage](#ii-routage)
    - [1. Mise en place du routage](#1-mise-en-place-du-routage)
    - [2. Analyse de trames](#2-analyse-de-trames-1)
    - [3. Accès internet](#3-accès-internet)
  - [III. DHCP](#iii-dhcp)
    - [1. Mise en place du serveur DHCP](#1-mise-en-place-du-serveur-dhcp)
    - [2. Analyse de trames](#2-analyse-de-trames-2)

## 0. Prérequis

➜ Pour ce TP, on va se servir de VMs Rocky Linux. 1Go RAM c'est large large. Vous pouvez redescendre la mémoire vidéo aussi.  

➜ Vous aurez besoin de deux réseaux host-only dans VirtualBox :

- un premier réseau `10.3.1.0/24`
- le second `10.3.2.0/24`
- **vous devrez désactiver le DHCP de votre hyperviseur (VirtualBox) et définir les IPs de vos VMs de façon statique**

➜ Les firewalls de vos VMs doivent **toujours** être actifs (et donc correctement configurés).

➜ **Si vous voyez le p'tit pote 🦈 c'est qu'il y a un PCAP à produire et à mettre dans votre dépôt git de rendu.**

## I. ARP

Première partie simple, on va avoir besoin de 2 VMs.

| Machine  | `10.3.1.0/24` |
|----------|---------------|
| `john`   | `10.3.1.11`   |
| `marcel` | `10.3.1.12`   |

```schema
   john               marcel
  ┌─────┐             ┌─────┐
  │     │    ┌───┐    │     │
  │     ├────┤ho1├────┤     │
  └─────┘    └───┘    └─────┘
```

> Référez-vous au [mémo Réseau Rocky](../../cours/memo/rocky_network.md) pour connaître les commandes nécessaire à la réalisation de cette partie.

### 1. Echange ARP

🌞**Générer des requêtes ARP**

- effectuer un `ping` d'une machine à l'autre

- observer les tables ARP des deux machines
- repérer l'adresse MAC de `john` dans la table ARP de `marcel` et vice-versa
- prouvez que l'info est correcte (que l'adresse MAC que vous voyez dans la table est bien celle de la machine correspondante)
  - une commande pour voir la MAC de `marcel` dans la table ARP de `john`
  - et une commande pour afficher la MAC de `marcel`, depuis `marcel`

  John : 

```
  [Adryx@localhost ~]$ ping 10.3.1.12
PING 10.3.1.12 (10.3.1.12) 56(84) bytes of data.
64 bytes from 10.3.1.12: icmp_seq=1 ttl=64 time=0.195 ms
64 bytes from 10.3.1.12: icmp_seq=2 ttl=64 time=0.401 ms
64 bytes from 10.3.1.12: icmp_seq=3 ttl=64 time=0.404 ms
64 bytes from 10.3.1.12: icmp_seq=4 ttl=64 time=0.378 ms
^C
--- 10.3.1.12 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3100ms
rtt min/avg/max/mdev = 0.195/0.344/0.404/0.086 ms
[Adryx@localhost ~]$ ip neigh show
10.3.1.12 dev enp0s8 lladdr 08:00:27:ed:46:eb REACHABLE
10.3.1.1 dev enp0s8 lladdr 0a:00:27:00:00:0f REACHABLE
[Adryx@localhost ~]$ i
-bash: i: command not found
[Adryx@localhost ~]$
[Adryx@localhost ~]$ ip neigh show 10.3.1.12
10.3.1.12 dev enp0s8 lladdr 08:00:27:ed:46:eb STALE
[Adryx@localhost ~]$
```

Marcel : 

```
[Adryx@localhost ~]$ ip neigh show
10.3.1.1 dev enp0s8 lladdr 0a:00:27:00:00:0f REACHABLE
10.3.1.11 dev enp0s8 lladdr 08:00:27:5d:27:9e STALE
[Adryx@localhost ~]$
[Adryx@localhost ~]$
[Adryx@localhost ~]$ ipconfig
-bash: ipconfig: command not found
[Adryx@localhost ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ed:46:eb brd ff:ff:ff:ff:ff:ff
    inet 10.3.1.12/24 brd 10.3.1.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feed:46eb/64 scope link
       valid_lft forever preferred_lft forever
[Adryx@localhost ~]$
```


### 2. Analyse de trames

🌞**Analyse de trames**

- utilisez la commande `tcpdump` pour réaliser une capture de trame
- videz vos tables ARP, sur les deux machines, puis effectuez un `ping`
```
sudo tcpdump -w tp3_arp.pcapng

ping 10.3.1.11
```

🦈 **Capture réseau `tp3_arp.pcapng`** qui contient un ARP request et un ARP reply

> **Si vous ne savez pas comment récupérer votre fichier `.pcapng`** sur votre hôte afin de l'ouvrir dans Wireshark, et me le livrer en rendu, demandez-moi.

## II. Routage

Vous aurez besoin de 3 VMs pour cette partie. **Réutilisez les deux VMs précédentes.**

| Machine  | `10.3.1.0/24` | `10.3.2.0/24` |
|----------|---------------|---------------|
| `router` | `10.3.1.254`  | `10.3.2.254`  |
| `john`   | `10.3.1.11`   | no            |
| `marcel` | no            | `10.3.2.12`   |

> Je les appelés `marcel` et `john` PASKON EN A MAR des noms nuls en réseau 🌻

```schema
   john                router              marcel
  ┌─────┐             ┌─────┐             ┌─────┐
  │     │    ┌───┐    │     │    ┌───┐    │     │
  │     ├────┤ho1├────┤     ├────┤ho2├────┤     │
  └─────┘    └───┘    └─────┘    └───┘    └─────┘
```

### 1. Mise en place du routage

🌞**Activer le routage sur le noeud `router`**

> Cette étape est nécessaire car Rocky Linux c'est pas un OS dédié au routage par défaut. Ce n'est bien évidemment une opération qui n'est pas nécessaire sur un équipement routeur dédié comme du matériel Cisco.

```
[Adryx@localhost ~]$ sudo firewall-cmd --list-all
[sudo] password for Adryx:
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s8 enp0s9
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
[Adryx@localhost ~]$ sudo firewall-cmd --get-active-zone
public
  interfaces: enp0s8 enp0s9
[Adryx@localhost ~]$ sudo firewall-cmd --add-masquerade --zone=public
success
[Adryx@localhost ~]$ sudo firewall-cmd --add-masquerade --zone=public --permanent
success
[Adryx@localhost ~]$
```


🌞**Ajouter les routes statiques nécessaires pour que `john` et `marcel` puissent se `ping`**

- il faut taper une commande `ip route add` pour cela, voir mémo
- il faut ajouter une seule route des deux côtés
- une fois les routes en place, vérifiez avec un `ping` que les deux machines peuvent se joindre

```
10.3.1.0/24 via 10.3.2.254 dev enp0s8 proto static metric 100
10.3.2.0/24 dev enp0s8 proto kernel scope link src 10.3.2.12 metric 100
```
```
[Adryx@localhost ~]$ ping 10.3.2.12
PING 10.3.2.12 (10.3.2.12) 56(84) bytes of data.
64 bytes from 10.3.2.12: icmp_seq=1 ttl=63 time=0.568 ms
64 bytes from 10.3.2.12: icmp_seq=2 ttl=63 time=0.710 ms
64 bytes from 10.3.2.12: icmp_seq=3 ttl=63 time=0.453 ms
^C
--- 10.3.2.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2044ms
rtt min/avg/max/mdev = 0.453/0.577/0.710/0.105 ms
```

![THE SIZE](./pics/thesize.png)

### 2. Analyse de trames

🌞**Analyse des échanges ARP**
```
Connection to 10.3.1.11 closed.
PS C:\Users\happy cash> scp Adryx@10.3.1.11:/home/Adryx/2.pcap           .
Adryx@10.3.1.11's password:
2.pcap
```

- videz les tables ARP des trois noeuds
```
sudo ip neigh flush all 
```

- effectuez un `ping` de `john` vers `marcel`
```
[Adryx@localhost ~]$ ping 10.3.1.11
PING 10.3.1.11 (10.3.1.11) 56(84) bytes of data.
64 bytes from 10.3.1.11: icmp_seq=1 ttl=63 time=0.689 ms
64 bytes from 10.3.1.11: icmp_seq=2 ttl=63 time=0.575 ms
64 bytes from 10.3.1.11: icmp_seq=3 ttl=63 time=0.452 ms
64 bytes from 10.3.1.11: icmp_seq=4 ttl=63 time=0.553 ms
64 bytes from 10.3.1.11: icmp_seq=5 ttl=63 time=0.470 ms
64 bytes from 10.3.1.11: icmp_seq=6 ttl=63 time=0.406 ms
64 bytes from 10.3.1.11: icmp_seq=7 ttl=63 time=0.454 ms
^C
--- 10.3.1.11 ping statistics ---
7 packets transmitted, 7 received, 0% packet loss, time 6753ms
rtt min/avg/max/mdev = 0.406/0.514/0.689/0.090 ms
``` 

- regardez les tables ARP des trois noeuds
- essayez de déduire un peu les échanges ARP qui ont eu lieu
```
He pense que ducoup Un request vas etre envoyé au rooter et le reply seras envoyé par celui ci car il gere la conexion entre les LAN'S
```

- répétez l'opération précédente (vider les tables, puis `ping`), en lançant `tcpdump` sur `marcel`
- **écrivez, dans l'ordre, les échanges ARP qui ont eu lieu, puis le ping et le pong, je veux TOUTES les trames** utiles pour l'échange

Par exemple (copiez-collez ce tableau ce sera le plus simple) :

| ordre | type trame  | IP source | MAC source              | IP destination | MAC destination            |
|-------|-------------|-----------|-------------------------|----------------|----------------------------|
| 1     | Requête ARP | x         | `marcel` `AA:BB:CC:DD:EE` | x              | Broadcast `FF:FF:FF:FF:FF` |
| 2     | Réponse ARP | x         | ?                       | x              | `marcel` `AA:BB:CC:DD:EE`    |
| ...   | ...         | ...       | ...                     |                |                            |
| 1    | Ping        | ?         | ?                       | ?              | ?                          |
| 2     | Pong        | ?         | ?                       | ?              | ?                          |

> Vous pourriez, par curiosité, lancer la capture sur `john` aussi, pour voir l'échange qu'il a effectué de son côté.

🦈 **Capture réseau `tp3_routage_marcel.pcapng`**

### 3. Accès internet

🌞**Donnez un accès internet à vos machines**

- ajoutez une carte NAT en 3ème inteface sur le `router` pour qu'il ait un accès internet
- ajoutez une route par défaut à `john` et `marcel`
  - vérifiez que vous avez accès internet avec un `ping`
  - le `ping` doit être vers une IP, PAS un nom de domaine
  ```
  [Adryx@localhost ~]$ sudo ip route add default via 10.3.2.254
[sudo] password for Adryx:
[Adryx@localhost ~]$ ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=53 time=25.4 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=53 time=23.4 ms
64 bytes from 1.1.1.1: icmp_seq=3 ttl=53 time=23.4 ms
64 bytes from 1.1.1.1: icmp_seq=4 ttl=53 time=28.6 ms
64 bytes from 1.1.1.1: icmp_seq=5 ttl=53 time=26.1 ms
64 bytes from 1.1.1.1: icmp_seq=6 ttl=53 time=22.9 ms
64 bytes from 1.1.1.1: icmp_seq=7 ttl=53 time=28.4 ms
64 bytes from 1.1.1.1: icmp_seq=8 ttl=53 time=23.2 ms
^C
--- 1.1.1.1 ping statistics ---
8 packets transmitted, 8 received, 0% packet loss, time 7148ms
rtt min/avg/max/mdev = 22.898/25.174/28.588/2.189 ms`
```

- donnez leur aussi l'adresse d'un serveur DNS qu'ils peuvent utiliser
  - vérifiez que vous avez une résolution de noms qui fonctionne avec `dig`
  - puis avec un `ping` vers un nom de domaine
  ```
  [Adryx@localhost ~]$ sudo cat /etc/resolv.conf
# Generated by NetworkManager
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
[Adryx@localhost ~]$ curl gitlan.com
^[[A[Adryx@localhost dig gitlab.com

; <<>> DiG 9.16.23-RH <<>> gitlab.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 22366
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;gitlab.com.                    IN      A

;; ANSWER SECTION:
gitlab.com.             65      IN      A       172.65.251.78

;; Query time: 27 msec
;; SERVER: 8.8.8.8#53(8.8.8.8)
;; WHEN: Mon Oct 24 12:13:36 CEST 2022
;; MSG SIZE  rcvd: 55

[Adryx@localhost ~]$ ^C
[Adryx@localhost ~]$ ping gitlab.com
PING gitlab.com (172.65.251.78) 56(84) bytes of data.
64 bytes from 172.65.251.78 (172.65.251.78): icmp_seq=1 ttl=53 time=23.6 ms
64 bytes from 172.65.251.78 (172.65.251.78): icmp_seq=2 ttl=53 time=23.7 ms
64 bytes from 172.65.251.78 (172.65.251.78): icmp_seq=3 ttl=53 time=22.8 ms
64 bytes from 172.65.251.78 (172.65.251.78): icmp_seq=4 ttl=53 time=24.5 ms
64 bytes from 172.65.251.78 (172.65.251.78): icmp_seq=5 ttl=53 time=23.8 ms
^C
--- gitlab.com ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4198ms
rtt min/avg/max/mdev = 22.755/23.652/24.455/0.546 ms
[Adryx@localhost ~]$
```


🌞**Analyse de trames**

- effectuez un `ping 8.8.8.8` depuis `john`
- capturez le ping depuis `john` avec `tcpdump`
- analysez un ping aller et le retour qui correspond et mettez dans un tableau :

| ordre | type trame | IP source                | MAC source                | IP destination | MAC destination    |     |
|-------|------------|--------------------------|---------------------------|----------------|--------------------|-----|
| 1     | ping       | `john` `10.3.1.11`       | `john` `08:00:27:d1:a8:6f`| `8.8.8.8`      |  08:00:27:11:ae:99 |     |
| 2     | pong       | 'rooter' '10.3.1.254'    | 08:00:27:11:ae:99         | ...            | ...                | ... |

🦈 **Capture réseau `tp3_routage_internet.pcapng`**

## III. DHCP

On reprend la config précédente, et on ajoutera à la fin de cette partie une 4ème machine pour effectuer des tests.

| Machine  | `10.3.1.0/24`              | `10.3.2.0/24` |
|----------|----------------------------|---------------|
| `router` | `10.3.1.254`               | `10.3.2.254`  |
| `john`   | `10.3.1.11`                | no            |
| `bob`    | oui mais pas d'IP statique | no            |
| `marcel` | no                         | `10.3.2.12`   |

```schema
   john               router              marcel
  ┌─────┐             ┌─────┐             ┌─────┐
  │     │    ┌───┐    │     │    ┌───┐    │     │
  │     ├────┤ho1├────┤     ├────┤ho2├────┤     │
  └─────┘    └─┬─┘    └─────┘    └───┘    └─────┘
   john        │
  ┌─────┐      │
  │     │      │
  │     ├──────┘
  └─────┘
```

### 1. Mise en place du serveur DHCP

🌞**Sur la machine `john`, vous installerez et configurerez un serveur DHCP** (go Google "rocky linux dhcp server").

- installation du serveur sur `john`
- créer une machine `bob`
- faites lui récupérer une IP en DHCP à l'aide de votre serveur

> Il est possible d'utilise la commande `dhclient` pour forcer à la main, depuis la ligne de commande, la demande d'une IP en DHCP, ou renouveler complètement l'échange DHCP (voir `dhclient -h` puis call me et/ou Google si besoin d'aide).

🌞**Améliorer la configuration du DHCP**

- ajoutez de la configuration à votre DHCP pour qu'il donne aux clients, en plus de leur IP :
  - une route par défaut
  - un serveur DNS à utiliser
- récupérez de nouveau une IP en DHCP sur `bob` pour tester :
  - `marcel` doit avoir une IP
    - vérifier avec une commande qu'il a récupéré son IP
    - vérifier qu'il peut `ping` sa passerelle
  - il doit avoir une route par défaut
    - vérifier la présence de la route avec une commande
    - vérifier que la route fonctionne avec un `ping` vers une IP
  - il doit connaître l'adresse d'un serveur DNS pour avoir de la résolution de noms
    - vérifier avec la commande `dig` que ça fonctionne
    - vérifier un `ping` vers un nom de domaine

### 2. Analyse de trames

🌞**Analyse de trames**

- lancer une capture à l'aide de `tcpdump` afin de capturer un échange DHCP
- demander une nouvelle IP afin de générer un échange DHCP
- exportez le fichier `.pcapng`

🦈 **Capture réseau `tp3_dhcp.pcapng`**