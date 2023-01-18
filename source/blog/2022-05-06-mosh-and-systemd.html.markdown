---
title: Mosh and systemd
author: Michał Zając
tags: ramblings
---

tl;dr if you want to use [Mosh](https://mosh.org) to connect to a systemd based Linux distribution then make sure you run it by `mosh --server="systemd-run --scope --user mosh-server"`.

## SSH over unstable connections

If you travel often and your connection is spotty then you probably know the pain of SSH disconnecting over the smallest thing. Most likely, you also experienced lag when typing which is *more* than annoying. Mosh aims to solve all those problems by building on top of SSH. It essentially connects to the SSH server you point it to, then spawns a `mosh-server` to which it then connects over random (some port between 60000 and 61000 to be precise) UDP port. You can learn more about the inner workings in the [Technical Section](https://mosh.org/#techinfo) of Mosh's website.

## Using mosh

Theoretically it should be simple as:

1. Make sure mosh is installed on both client and server
2. `mosh user@ip`

Simple, right? Alright, let's go

```
me@client $ mosh me@server
<nothing happens>

Nothing received from the server on UDP port 60003
```

Crap. Alright, there's a [FAQ](https://mosh.org/#faq) entry for this:

>This generally means that some type of firewall is blocking the UDP packets between the client and the server. If you had to forward TCP port 22 on a NAT for SSH, then you will have to forward UDP ports as well. Mosh will use the first available UDP port, starting at 60001 and stopping at 60999. If you are only going to have a small handful of concurrent sessions on a server, then you can forward a smaller range of ports (e.g., 60000 to 60010). 

## Making sure UDP connection works

On the server I ran:

```
me@server $ nc -w 0 -lu 60001
```

and then on the client:

```
me@client $ nc -w 0 -u 100.98.222.87 60001 <<EOF
hello
EOF
```

and sure enough, I did see `hello` on the server:

```
me@server $ nc -w 0 -lu 60001
hello

me@server $
```

Clearly it's something else...

## tcpdump everything

Maybe some packets are not making it through? Time to whip out tcpdump:

```
me@client $ sudo tcpdump -eni tailscale0 port 60001
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on tailscale0, link-type RAW (Raw IP), capture size 262144 bytes
23:31:37.514860 ip: 100.113.77.93.38477 > 100.98.222.87.60001: UDP, length 78
23:31:40.507077 ip: 100.113.77.93.38477 > 100.98.222.87.60001: UDP, length 82
23:31:43.506815 ip: 100.113.77.93.38477 > 100.98.222.87.60001: UDP, length 86
23:31:46.506639 ip: 100.113.77.93.38477 > 100.98.222.87.60001: UDP, length 71
23:31:49.507357 ip: 100.113.77.93.38477 > 100.98.222.87.60001: UDP, length 80
23:31:52.508372 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 78
23:31:52.759241 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 78
23:31:53.010173 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 87
23:31:53.260988 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 82
23:31:53.511715 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 87
23:31:53.762557 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 77
23:31:54.013368 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 79
23:31:54.264270 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 77
23:31:54.515092 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 87
23:31:54.765977 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 79
23:31:55.016703 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 77
23:31:55.267424 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 73
23:31:55.518142 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 81
23:31:55.768973 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 76
23:31:56.019911 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 81
23:31:56.270618 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 82
```

also make sure it's running on the server so we can determine if everything works nice:

```
me@server $ sudo tcpdump -eni tailscale0 port 60001
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on tailscale0, link-type RAW (Raw IP), capture size 262144 bytes
23:31:37.978571 ip: 100.113.77.93.38477 > 100.98.222.87.60001: UDP, length 78
23:31:40.621810 ip: 100.113.77.93.38477 > 100.98.222.87.60001: UDP, length 82
23:31:43.591764 ip: 100.113.77.93.38477 > 100.98.222.87.60001: UDP, length 86
23:31:46.662669 ip: 100.113.77.93.38477 > 100.98.222.87.60001: UDP, length 71
23:31:49.683577 ip: 100.113.77.93.38477 > 100.98.222.87.60001: UDP, length 80
23:31:52.706635 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 78
23:31:52.790623 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 78
23:31:53.114457 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 87
23:31:53.322499 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 82
23:31:53.625159 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 87
23:31:53.832249 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 77
23:31:54.070419 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 79
23:31:54.753549 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 77
23:31:54.753639 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 87
23:31:54.849537 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 79
23:31:55.161667 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 77
23:31:55.367760 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 73
23:31:55.640406 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 81
23:31:55.880897 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 76
23:31:56.130086 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 81
23:31:56.431117 ip: 100.113.77.93.51071 > 100.98.222.87.60001: UDP, length 82
```

No dice, everything goes through but I'm still seeing `Nothing received from the server on UDP port 60003`. What the hell is going on?

## `mosh-client` and `mosh-server`

Actually `mosh` is just a wrapper that connects via SSH and starts `mosh-server` on the server, gets an AES-128 session key and uses that to connect via `mosh-client`. Let's see if I can establish a connection:

```
me@server $ mosh-server new          


MOSH CONNECT 60003 +5IhAj5k8QIoIxp7xvk7Tw

mosh-server (mosh 1.3.2) [build mosh 1.3.2]
Copyright 2012 Keith Winstein <mosh-devel@mit.edu>
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

[mosh-server detached, pid = 131157]
```

```
me@client $ MOSH_KEY=+5IhAj5k8QIoIxp7xvk7Tw mosh-client me@server 60003

Welcome to KDE neon User - Plasma 5.24 (GNU/Linux 5.4.0-109-generic x86_64)
Last login: Fri May  6 01:26:56 2022 from 100.113.77.93

me@server $
```

Holy cow, it works!

## Schrödinger's process

My initial idea was that `mosh-server` was dying/crashing/being killed for some reason  since I could briefly see it when doing `ps aux | grep mosh` over a regular SSH connection but after a second or so it disappeared.

By default `sshd` doesn't provide that much information so I started another `sshd` in debug mode

```
me@server $ sudo /usr/sbin/sshd -4Ddep 2222
```

and tried moshing to it

```
me@client $ mosh --ssh="ssh -p 2222" me@server
```

then on the server

```
[metric crapton of debug output]
Connection from 100.113.77.93 port 52912 on 100.98.222.87 port 2222 rdomain ""
[more output]
Starting session: command on pts/5 for quintasan from 100.113.77.93 port 52912 id 0
[more debug]
Received disconnect from 100.113.77.93 port 52912:11: disconnected by user
Disconnected from user quintasan 100.113.77.93 port 52912
[some more debug]
```

off to the client we go:

```
me@client $ mosh --ssh="ssh -p 2222" me@server

Welcome to KDE neon User - Plasma 5.24 (GNU/Linux 5.4.0-109-generic x86_64)
Last login: Fri May  6 01:26:56 2022 from 100.113.77.93

me@server $
```

Okay... what?

## Debugging sshd

Well, time to debug what's going on with the actual `sshd` ran by systemd since I'm clearly not getting anywhere:

```
me@server $ sudo echo 'LogLevel DEBUG3' >> /etc/ssh/sshd_config
me@server $ sudo systemctl restart ssh.service
me@server $ journalctl -fu ssh.service
```

It's time to connect and inspect the logs:

```
maj 06 00:07:07 shurelia sshd[107281]: Connection from 100.113.77.93 port 43280 on 100.98.222.87 port 22 rdomain ""

[metric crapton of debug output]

maj 06 00:07:08 shurelia sshd[107281]: Accepted key ED25519 SHA256:pSss8PC89BlLwww188Y0OIoVXsVaoDShUM0ZoyJQReQ found at /home/quintasan/.ssh/authorized_keys:3

[more debug output]

maj 06 00:07:08 shurelia sshd[107281]: pam_unix(sshd:session): session opened for user quintasan by (uid=0)
maj 06 00:07:08 shurelia sshd[107281]: User child is on pid 107311
maj 06 00:07:09 shurelia sshd[107281]: debug1: PAM: cleanup
maj 06 00:07:09 shurelia sshd[107281]: debug1: PAM: closing session
maj 06 00:07:09 shurelia sshd[107281]: pam_unix(sshd:session): session closed for user quintasan

[even more debug output]
```

At this point I'm pretty much sure it's PAM killing all processes. But why would it do that?

## Google-fu

My journey came to an abrupt end by Googling `pam killing mosh-server` which returned a link to [Unable to connect since recently](https://github.com/mobile-shell/mosh/issues/730) (March 2016) which quickly points out that the culprit is `systemd-logind` which kills all remaining processes when session closes if `KillUserProcesses` is set to `yes` in `/etc/systemd/logind.conf`.

```
me@server $ cat /etc/systemd/logind.conf | grep KillUserProcesses
#KillUserProcesses=no
```

Hm, maybe it's yes by default. I uncommented it, did `sudo systemctl restart systemd-logind.service` and tried Mosh again:

```
me@client $ mosh me@server
<nothing happens>

Nothing received from the server on UDP port 60003
```

Well. That didn't go well. I quickly found [/etc/systemd/logind.conf is being ignored](https://superuser.com/questions/1605504/etc-systemd-logind-conf-is-being-ignored) and tried `busctl` command to read the configuration

```
me@server $ busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager KillUserProcesses
b true
```

Okay, whatever. There's also `KillExcludeUsers=root` in `/etc/systemd/logind.conf` to which I added myself, restarted `systemd-logind.service` and...

```
me@client $ mosh me@server

Welcome to KDE neon User - Plasma 5.24 (GNU/Linux 5.4.0-109-generic x86_64)
Last login: Fri May  6 01:26:56 2022 from 100.113.77.93

me@server $
```

## What does this mean?

If I took some time to read the whole issue I would have seen that `systemd-run --scope --user` is meant to solve this problem so `mosh --server="systemd-run --scope --user mosh-server"` would have gotten me the same result without chaning any systemd configuration files.

Truth be told, at this point I already wasted 2 hours trying to debug this thing so I don't really understand the difference between `systemd-run --scope --user` and disabling `KillUserProcesses` (or adding myself to `KillExcludeUsers`) which is something I'll probably investigate at a later date.
