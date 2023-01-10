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

[Adryx@Adryx ~]$
```

## 🌞 Formater la partition