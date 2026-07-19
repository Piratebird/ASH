<div align="center">

```text
   ░███      ░██████   ░██     ░██ 
  ░██░██    ░██   ░██  ░██     ░██ 
 ░██  ░██  ░██         ░██     ░██ 
░█████████  ░████████  ░██████████ 
░██    ░██         ░██ ░██     ░██ 
░██    ░██  ░██   ░██  ░██     ░██ 
░██    ░██   ░██████   ░██     ░██ 
```

**Some call it spyware, I call it spaghetti.**  

</div>

---

## Table of Contents

- [Why this exists](#why-this-exists)
- [The Stack](#the-stack)
- [Features](#features)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Usage (Endpoints)](#usage-endpoints)
- [Disclaimer](#disclaimer)

**Current State:** Complete / Stable

ASH is an API and Web Dashboard written entirely in Bash (sometimes I wonder why I do this to myself). Instead of using bloated JS frameworks or Python, this bozo uses `lighttpd` and raw bash CGI scripts to monitor your server and serve web endpoints.

check live demo: [ASH](https://ash-r5tv.onrender.com/cgi-bin/dashboard.sh)

Some people call it spyware, I call it spaghetti.
---

## Why this exists

tbh I have no clue why I do this to myself. I no longer wanna touch bash for ages, but it was nice to see it actually work. 

This project was heavily inspired by the goat [ysap](https://ysap.sh/youtube) and his [site](https://github.com/bahamas10/ysap).

## The Stack

* **Web Server:** lighttpd
* **Backend:** Pure Bash (CGI)
* **Frontend:** HTML, Vanilla JS, CSS
* **Theme:** Catppuccin Mocha

## Features

1. Live Server Dashboard for CPU, RAM, Disk, and Docker containers.
2. Client Device Mirror to securely display visitor specs.
3. Native curl support with ASCII terminal UI responses.
4. Custom endpoints for fetching programming jokes and Pokemon cards.

## Project Structure

- `cgi-bin/`: The core backend API endpoints and scripts.
- `libs/`: Shared bash libraries (colors, HTTP headers, template rendering).
- `templates/`: HTML structures and components used by the bash scripts.
- `static/`: CSS and styling files.
- `setup.sh`: Interactive cross-platform deployment wizard.

---

## Dependencies

You'll need a Linux environment (or macOS). The setup script automatically handles the heavy lifting, but under the hood it relies on:
- `lighttpd`
- `bash`
- `curl`
- `procps`
- `iproute2`

> **Note for Windows Users:** ASH is a native Linux application. If you are on Windows, you must run this inside **WSL** (Windows Subsystem for Linux) or via Docker Desktop.

## Installation

You have two choices for this bozo: you can either run it natively on your host machine to monitor your actual hardware, or you can chuck it into a Docker container to sandbox it.

```bash
# Clone the repo
git clone https://github.com/Piratebird/ASH.git
cd ASH

# Run the setup wizard
./setup.sh
```

If you choose the Docker container, it builds a tiny Alpine Linux image and sandboxes the dashboard. If you choose Native, it installs the dependencies via your package manager (apt/dnf/pacman/brew) and optionally sets up a systemd background service.

<br>

## Usage (Endpoints)

Once it's running, you can access the graphical dashboard in your web browser at `http://localhost:8080`.

Since it's an API, you can also curl the endpoints directly from your terminal to get colorized ASCII output:

```bash
# Main help menu
curl http://localhost:8080/cgi-bin/welcome.sh

# System vitals
curl http://localhost:8080/cgi-bin/status.sh
curl http://localhost:8080/cgi-bin/top.sh
curl http://localhost:8080/cgi-bin/du.sh

# Client / Visitor info
curl http://localhost:8080/cgi-bin/client.sh
curl http://localhost:8080/cgi-bin/device_info.sh

# Fun stuff
curl http://localhost:8080/cgi-bin/joke.sh
curl http://localhost:8080/cgi-bin/pokemon.sh
```

## Disclaimer

This is purely educational analytics shenanigans for the heck of it. 

No information is sent to a remote server. The Client Device mirror relies entirely on safe, local web APIs and header parsing. 

However you use this tool is your responsibility gangster.
