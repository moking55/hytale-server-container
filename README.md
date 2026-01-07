# Docker Hytale Server

Minimal, hardened Docker image for running a Hytale server.
Optimized for **performance**, **security**, and **QUIC/UDP networking**.

---

## General info

- The server jar is baked into the docker image. Hytale only works with the most up to date version for client and server. (Bypass is coming for developers)

## Features

### 💡 Useful

- **Automated network checks**  
  Checks the if the server port is avaiable, port conflicts, quic readiness, internet connectivity, public ip detection and server ip validity nonblocking.

- **Automated security checks**  
  Verifies the server JAR integrity and read-only permissions, ensures `no-new-privileges` and `cap_drop: ALL` are enforced, confirms the container is running as non-root, and checks system clock synchronization with network time.

- **Production readiness checks**  
  Checks Java heap against Docker memory limits, system entropy, /tmp writability, non-root execution, file descriptor limits, noexec on /tmp, huge pages, system time, disk IO, process/thread limits, UDP buffer sizes, leftover lockfiles, filesystem type, OOM risk, swap usage, and clock stability.  
  `Activate by setting the PROD environment variable to "TRUE".`


### 🛡️ Security

- **Non-Root Execution**  
  Runs as a dedicated `hytale` user (UID/GID configurable).

- **Minimal Attack Surface**  
  Only essential runtime packages included.

- **Capability Safe**  
  Compatible with:
  - `cap_drop: ALL`
  - `no-new-privileges: true`
  - Read-only root filesystem (Only data folder has read/write)

- **Proper Init System**  
  Uses `tini` to correctly handle signals and prevent zombie processes.

---

### ⚡ Performance & Networking

- **QUIC / UDP Optimized**  
  Designed for Hytale’s native UDP-based networking.

- **Multi-Architecture**  
  Supports `amd64` and `arm64`.

- **Production Healthcheck**  
  Uses `ss` to verify UDP listener availability.

- **Fast & Deterministic Builds**  
  Uses BuildKit mounts and checksum verification.

---

## Environment Variables

| Variable | Required | Description |
|--------|--------|------------|
| `EULA` | ✅ | Must be set to `TRUE` to accept the Hytale EULA |
| `JAVA_OPTS` | ❌ | JVM flags (e.g. `-Xms4G -Xmx4G`) |
| `UID` | ❌ | Runtime user ID (default: 1000) |
| `GID` | ❌ | Runtime group ID (default: 1000) |
| `SERVER_PORT` | ❌ | UDP port (default: 25565) |
| `TZ` | ❌ | Timezone (default: UTC) |

---

## Building the Image

The server JAR is **included in the image during build**. Provide the JAR file URL at build time, along with its SHA256 hash to verify the file’s integrity.  

The reason this is done is that Hytale requires the latest version of the game to be enforced for clients.


With cache:
```bash
docker build \
  --build-arg SERVER_JAR_URL="https://example.com/hytale-server.jar" \
  --build-arg SERVER_JAR_SHA256="sha256sum_here" \
  -t docker-hytale-server:latest .
```

Without cache and with logs:
```bash 
docker build \
  --build-arg SERVER_JAR_URL="https://example.com/hytale-server.jar" \
  --build-arg SERVER_JAR_SHA256="sha256sum_here" \
  --progress=plain --no-cache \
  -t docker-hytale-server:latest .
```

You can use the website [hash-file.online](https://hash-file.online/) to get the SHA-256 HASH of the .jar file.