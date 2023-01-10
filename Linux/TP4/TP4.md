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

