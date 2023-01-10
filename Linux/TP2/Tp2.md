# I

Le service SSH est alumé :

```
[Adryx@localhost ~]$ systemctl status
● Adryx
    State: degraded
     Jobs: 0 queued
   Failed: 2 units
    Since: Fri 2022-12-09 16:23:35 CET; 19min ago
   CGroup: /
           ├─init.scope
           │ └─1 /usr/lib/systemd/systemd --switched-root --system --deserialize 18
           ├─system.slice
           │ ├─NetworkManager.service
           │ │ └─884 /usr/sbin/NetworkManager --no-daemon
           │ ├─auditd.service
           │ │ └─675 /sbin/auditd
           │ ├─chronyd.service
           │ │ └─713 /usr/sbin/chronyd -F 2
           │ ├─crond.service
           │ │ └─741 /usr/sbin/crond -n
           │ ├─dbus-broker.service
           │ │ ├─718 /usr/bin/dbus-broker-launch --scope system --audit
           │ │ └─720 dbus-broker --log 4 --controller 9 --machine-id 3b7416658b6a4b32bc82c5b534ae7d10 --max-bytes 53687>
           │ ├─firewalld.service
           │ │ └─704 /usr/bin/python3 -s /usr/sbin/firewalld --nofork --nopid
           │ ├─irqbalance.service
           │ │ └─705 /usr/sbin/irqbalance --foreground
           │ ├─rsyslog.service
           │ │ └─706 /usr/sbin/rsyslogd -n
           │ ├─sshd.service
           │ │ └─732 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
           │ ├─systemd-journald.service
``` 

🌞 Analyser les processus liés au service SSH

```
// sans filtre

[Adryx@localhost ~]$ ps
    PID TTY          TIME CMD
    996 pts/0    00:00:00 bash
   1073 pts/0    00:00:00 ps
```
```
//Avec filtre`
[Adryx@Adryx log]$ ps | grep bash
   1114 pts/0    00:00:00 bash
``

🌞 Déterminer le port sur lequel écoute le service SSH

```
[Adryx@localhost ~]$ ss |grep ssh
tcp   ESTAB 0      52                        10.3.2.2:ssh       10.3.2.1:53823
```

🌞 Consulter les logs du service SSH

```
[Adryx@localhost ~]$ journalctl
Dec 09 16:23:33 localhost kernel: Linux version 5.14.0-70.26.1.el9_0.x86_64 (mockbuild@dal1-prod-builder001.bld.equ.roc>Dec 09 16:23:33 localhost kernel: The list of certified hardware and cloud instances for Red Hat Enterprise Linux 9 can>Dec 09 16:23:33 localhost kernel: Command line: BOOT_IMAGE=(hd0,msdos1)/vmlinuz-5.14.0-70.26.1.el9_0.x86_64 root=/dev/m>Dec 09 16:23:33 localhost kernel: x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
Dec 09 16:23:33 localhost kernel: x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
Dec 09 16:23:33 localhost kernel: x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
Dec 09 16:23:33 localhost kernel: x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
Dec 09 16:23:33 localhost kernel: x86/fpu: Enabled xstate features 0x7, context size is 832 bytes, using 'standard' for>Dec 09 16:23:33 localhost kernel: signal: max sigframe size: 1776
Dec 09 16:23:33 localhost kernel: BIOS-provided physical RAM map:
Dec 09 16:23:33 localhost kernel: BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
Dec 09 16:23:33 localhost kernel: BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
lines 1-12...skipping...
```
```
[Adryx@Adryx log]$ ls
anaconda  audit  btmp  chrony  cron  dnf.librepo.log  dnf.log  dnf.rpm.log  firewalld  hawkey.log  lastlog  maillog  messages  private  README  secure  spooler  sssd  tallylog  wtmp
[Adryx@Adryx log]$ tail -n 10 secure
tail: cannot open 'secure' for reading: Permission denied
[Adryx@Adryx log]$ sudo !!
sudo tail -n 10 secure
[sudo] password for Adryx:
Dec  9 16:35:29 localhost login[1024]: pam_unix(login:auth): check pass; user unknown
Dec  9 16:35:29 localhost login[1024]: pam_unix(login:auth): authentication failure; logname= uid=0 euid=0 tty=/dev/tty1 ruser= rhost=
Dec  9 16:35:31 localhost login[1024]: FAILED LOGIN 1 FROM tty1 FOR azerr, Authentication failure
Dec  9 16:35:34 localhost login[1024]: pam_unix(login:session): session opened for user Adryx(uid=1000) by (uid=0)
Dec  9 16:35:34 localhost login[1024]: LOGIN ON tty1 BY Adryx
Dec  9 17:01:51 localhost sshd[995]: Received disconnect from 10.3.2.1 port 53823:11: disconnected by user
Dec  9 17:01:51 localhost sshd[995]: Disconnected from user Adryx 10.3.2.1 port 53823
Dec  9 17:01:51 localhost sshd[991]: pam_unix(sshd:session): session closed for user Adryx
Dec  9 17:01:54 localhost sshd[1109]: Accepted password for Adryx from 10.3.2.1 port 57207 ssh2
Dec  9 17:01:54 localhost sshd[1109]: pam_unix(sshd:session): session opened for user Adryx(uid=1000) by (uid=0)
```





