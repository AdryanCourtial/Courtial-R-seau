# Partie 1

## 🌞 Partitionner le disque à l'aide de LVM

```
[Adryx@Adryx ~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0    8G  0 disk
├─sda1        8:1    0    1G  0 part /boot
└─sda2        8:2    0    7G  0 part
  ├─rl-root 253:0    0  6.2G  0 lvm  /
  └─rl-swap 253:1    0  820M  0 lvm  [SWAP]
sdb           8:16   0    2G  0 disk
sr0          11:0    1 1024M  0 rom
sr1          11:1    1  1.4G  0 rom
[Adryx@Adryx ~]$ pv create /dev/sdb
-bash: pv: command not found
[Adryx@Adryx ~]$ pvcreate /dev/sdb
  WARNING: Running as a non-root user. Functionality may be unavailable.
  /run/lock/lvm/P_global:aux: open failed: Permission denied
[Adryx@Adryx ~]$ sudo !!
sudo pvcreate /dev/sdb
[sudo] password for Adryx:
  Physical volume "/dev/sdb" successfully created.
[Adryx@Adryx ~]$ pvsdisplay
-bash: pvsdisplay: command not found
[Adryx@Adryx ~]$ pvdisplay
  WARNING: Running as a non-root user. Functionality may be unavailable.
  /run/lock/lvm/P_global:aux: open failed: Permission denied
[Adryx@Adryx ~]$ sudo !!
sudo pvdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB5b934acc-29a532a3_ PVID LFBmiT3hL5eby2cRK9IyI3jOMxuXJroD last seen on /dev/sda2 not found.
  "/dev/sdb" is a new physical volume of "2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name
  PV Size               2.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               riXbLH-VaGb-0aEM-8TXk-Z0hC-yFnV-H5t7dd

[Adryx@Adryx ~]$
```

```
[Adryx@Adryx ~]$ vgcreate storage /dev/sdb
  WARNING: Running as a non-root user. Functionality may be unavailable.
  /run/lock/lvm/P_global:aux: open failed: Permission denied
[Adryx@Adryx ~]$ sudo !!
sudo vgcreate storage /dev/sdb
  Volume group "storage" successfully created
[Adryx@Adryx ~]$ vgs
  WARNING: Running as a non-root user. Functionality may be unavailable.
  /run/lock/lvm/P_global:aux: open failed: Permission denied
[Adryx@Adryx ~]$ sudo !!
sudo vgs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB5b934acc-29a532a3_ PVID LFBmiT3hL5eby2cRK9IyI3jOMxuXJroD last seen on /dev/sda2 not found.
  VG      #PV #LV #SN Attr   VSize  VFree
  storage   1   0   0 wz--n- <2.00g <2.00g
[Adryx@Adryx ~]$ sudo vgdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB5b934acc-29a532a3_ PVID LFBmiT3hL5eby2cRK9IyI3jOMxuXJroD last seen on /dev/sda2 not found.
  --- Volume group ---
  VG Name               storage
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <2.00 GiB
  PE Size               4.00 MiB
  Total PE              511
  Alloc PE / Size       0 / 0
  Free  PE / Size       511 / <2.00 GiB
  VG UUID               hI7r3x-1SVS-xvkX-BCPU-X7XH-kGqQ-jmyKfn
```
```
[Adryx@Adryx ~]$ sudo lvcreate -L 2G storage -n web
  Volume group "storage" has insufficient free space (511 extents): 512 required.
[Adryx@Adryx ~]$ sudo lvcreate -l 100%FREE storage -n web_data
  Logical volume "web_data" created.
[Adryx@Adryx ~]$ lvs
  WARNING: Running as a non-root user. Functionality may be unavailable.
  /run/lock/lvm/P_global:aux: open failed: Permission denied
[Adryx@Adryx ~]$ sudo !!
sudo lvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB5b934acc-29a532a3_ PVID LFBmiT3hL5eby2cRK9IyI3jOMxuXJroD last seen on /dev/sda2 not found.
  LV       VG      Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  web_data storage -wi-a----- <2.00g
[Adryx@Adryx ~]$ sudo lvdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB5b934acc-29a532a3_ PVID LFBmiT3hL5eby2cRK9IyI3jOMxuXJroD last seen on /dev/sda2 not found.
  --- Logical volume ---
  LV Path                /dev/storage/web_data
  LV Name                web_data
  VG Name                storage
  LV UUID                0n2y6P-3QDJ-Hbgt-DuIM-lo8R-i0PC-8q2eVc
  LV Write Access        read/write
  LV Creation host, time Adryx, 2023-01-10 16:46:13 +0100
  LV Status              available
  # open                 0
  LV Size                <2.00 GiB
  Current LE             511
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
```

[Adryx@Adryx ~]$

## 🌞 Formater la partition

```
[Adryx@Adryx ~]$ mkfs -t ext4 /dev/storage/web_data
mke2fs 1.46.5 (30-Dec-2021)
mkfs.ext4: Permission denied while trying to determine filesystem size
[Adryx@Adryx ~]$ sudo !!
sudo mkfs -t ext4 /dev/storage/web_data
[sudo] password for Adryx:
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: e42633ac-4a1e-4c94-9b9c-be0a2014b5b6
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done

[Adryx@Adryx ~]$

```

## 🌞 Monter la partition

```
[Adryx@Adryx ~]$ mkdir /mnt/storage
mkdir: cannot create directory ‘/mnt/storage’: Permission denied
[Adryx@Adryx ~]$ sudo !!
sudo mkdir /mnt/storage
[Adryx@Adryx ~]$ mount /dev/storage/web_data /mnt/storage/
mount: /mnt/storage: must be superuser to use mount.
[Adryx@Adryx ~]$ sudo !!
[Adryx@Adryx ~]$ df -h
Filesystem                    Size  Used Avail Use% Mounted on
devtmpfs                      462M     0  462M   0% /dev
tmpfs                         481M     0  481M   0% /dev/shm
tmpfs                         193M  3.0M  190M   2% /run
/dev/mapper/rl-root           6.2G  1.2G  5.1G  18% /
/dev/sda1                    1014M  210M  805M  21% /boot
tmpfs                          97M     0   97M   0% /run/user/1000
/dev/mapper/storage-web_data  2.0G   24K  1.9G   1% /mnt/storage
[Adryx@Adryx ~]$ mount | grep ext4
/dev/mapper/storage-web_data on /mnt/storage type ext4 (rw,relatime,seclabel)
[Adryx@Adryx ~]$
```

```
[Adryx@Adryx ~]$ sudo nano  /etc/fstab
[Adryx@Adryx ~]$ sudo umount /mnt/storage/
[Adryx@Adryx ~]$
[Adryx@Adryx ~]$
[Adryx@Adryx ~]$
[Adryx@Adryx ~]$ sudo mount -a
mount: /etc/fstab: parse error at line 15 -- ignored
[Adryx@Adryx ~]$ sudo mount -av
mount: /etc/fstab: parse error at line 15 -- ignored
/                        : ignored
/boot                    : already mounted
none                     : ignored
[Adryx@Adryx ~]$ sudo vim  /etc/fstab
[Adryx@Adryx ~]$
[Adryx@Adryx ~]$
[Adryx@Adryx ~]$
[Adryx@Adryx ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /mnt/storage does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
```


# PARTIE 2

🌞 Donnez les commandes réalisées sur le serveur NFS storage.tp4.linux

```
[Adryx@Storage ~]$ sudo dnf install nfs-utils
```
```
[Adryx@Storage ~]$ sudo mkdir /storage/site_web_1 -p
[Adryx@Storage ~]$ sudo mkdir /storage/site_web_2 -p
[Adryx@Storage ~]$ ls
storage
[Adryx@Storage ~]$ cd st
-bash: cd: st: No such file or directory
[Adryx@Storage ~]$ cd storage/
[Adryx@Storage storage]$ ls
site_web_1  site_web_2
[Adryx@Storage storage]$ ls -al
total 0
drwxr-xr-x. 4 Adryx Adryx 42 Jan 16 15:24 .
drwx------. 3 Adryx Adryx 98 Jan 10 17:03 ..
drwxr-xr-x. 2 root  root   6 Jan 16 15:24 site_web_1
drwxr-xr-x. 2 root  root   6 Jan 16 15:24 site_web_2
[Adryx@Storage storage]$ sudo chown Adryx site_web_1 site_web_2
[Adryx@Storage storage]$ ls -al
total 0
drwxr-xr-x. 4 Adryx Adryx 42 Jan 16 15:24 .
drwx------. 3 Adryx Adryx 98 Jan 10 17:03 ..
drwxr-xr-x. 2 Adryx root   6 Jan 16 15:24 site_web_1
drwxr-xr-x. 2 Adryx root   6 Jan 16 15:24 site_web_2
[Adryx@Storage storage]$
```

```
 nano /etc/exports
[Adryx@Storage storage]$ sudo !!
sudo nano /etc/exports
[Adryx@Storage storage]$
```

```
sudo systemctl enable nfs-server
[sudo] password for Adryx:
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[Adryx@Storage ~]$ sudo systemctl start nfs-server
[Adryx@Storage ~]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Mon 2023-01-16 15:37:02 CET; 12s ago
    Process: 11393 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=1/FAILURE)
    Process: 11394 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
    Process: 11412 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=e>
   Main PID: 11412 (code=exited, status=0/SUCCESS)
        CPU: 23ms

Jan 16 15:37:02 Storage exportfs[11393]: exportfs: No options for GNU /etc/exports: suggest /etc/exports(sync) to avoid>
Jan 16 15:37:02 Storage exportfs[11393]: exportfs: Invalid IP address /etc/exports
Jan 16 15:37:02 Storage exportfs[11393]: exportfs: Invalid IP address /etc/exports
Jan 16 15:37:02 Storage exportfs[11393]: exportfs: No options for GNU Modified: suggest Modified(sync) to avoid warning
Jan 16 15:37:02 Storage exportfs[11393]: exportfs: Failed to resolve Modified
Jan 16 15:37:02 Storage exportfs[11393]: exportfs: Failed to resolve Modified
Jan 16 15:37:02 Storage exportfs[11393]: exportfs: Failed to stat /storage/site_web_2: No such file or directory
Jan 16 15:37:02 Storage exportfs[11393]: exportfs: Failed to stat /storage/site_web_1: No such file or directory
Jan 16 15:37:02 Storage exportfs[11393]: exportfs: Failed to stat GNU: No such file or directory
Jan 16 15:37:02 Storage systemd[1]: Finished NFS server and services.
```

```
[Adryx@Storage ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client nfs ssh
```

```
[Adryx@Storage ~]$ sudo firewall-cmd --permanent --add-service=nfs
success
[Adryx@Storage ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[Adryx@Storage ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[Adryx@Storage ~]$ sudo firewall-cmd --reload
success
[Adryx@Storage ~]$
```

🌞 Donnez les commandes réalisées sur le client NFS web.tp4.linux
```
[Adryx@Web ~]$ sudo dnf install nfs-utils
```

```
[Adryx@Web ~]$ sudo mkdir -p /var/www/site_web_1
[sudo] password for Adryx:
[Adryx@Web ~]$ sudo mkdir -p /var/www/site_web_2
[Adryx@Web ~]$ sudo chown Adryx /var/www/site_web_1 /var/www/site_web_2
[Adryx@Web ~]$ ls -al
total 12
drwx------. 2 Adryx Adryx  62 Oct 13 11:05 .
drwxr-xr-x. 3 root  root   19 Oct 13 11:05 ..
-rw-r--r--. 1 Adryx Adryx  18 May 16  2022 .bash_logout
-rw-r--r--. 1 Adryx Adryx 141 May 16  2022 .bash_profile
-rw-r--r--. 1 Adryx Adryx 492 May 16  2022 .bashrc
[Adryx@Web ~]$
```
```
[Adryx@Web ~]$ sudo mount 10.3.2.10:/storage/site_web_1 /var/www/site_web_1
[Adryx@Web ~]$
[Adryx@Web ~]$ sudo mount 10.3.2.10:/storage/site_web_1 /var/www/site_web_1
[Adryx@Web ~]$ df -h
Filesystem                     Size  Used Avail Use% Mounted on
devtmpfs                       462M     0  462M   0% /dev
tmpfs                          481M     0  481M   0% /dev/shm
tmpfs                          193M  3.0M  190M   2% /run
/dev/mapper/rl-root            6.2G  1.2G  5.1G  18% /
/dev/sda1                     1014M  210M  805M  21% /boot
tmpfs                           97M     0   97M   0% /run/user/1000
10.3.2.10:/storage/site_web_1  6.2G  1.2G  5.1G  18% /var/www/site_web_1
[Adryx@Web ~]$
[Adryx@Web ~]$
[Adryx@Web ~]$ sudo mount 10.3.2.10:/storage/site_web_2 /var/www/site_web_2
[Adryx@Web ~]$ df -h
Filesystem                     Size  Used Avail Use% Mounted on
devtmpfs                       462M     0  462M   0% /dev
tmpfs                          481M     0  481M   0% /dev/shm
tmpfs                          193M  3.0M  190M   2% /run
/dev/mapper/rl-root            6.2G  1.2G  5.1G  18% /
/dev/sda1                     1014M  210M  805M  21% /boot
tmpfs                           97M     0   97M   0% /run/user/1000
10.3.2.10:/storage/site_web_1  6.2G  1.2G  5.1G  18% /var/www/site_web_1
10.3.2.10:/storage/site_web_2  6.2G  1.2G  5.1G  18% /var/www/site_web_2
```
# PARTIT 3

```
ps -ef | grep XGINX
Adryx       2488     848  0 17:13 pts/0    00:00:00 grep --color=auto XGINX
```

```
[Adryx@Web site_web_1]$ ss | grep nfs
tcp   ESTAB  0      0                        10.3.2.13:iscsi        10.3.2.10:nfs
```

