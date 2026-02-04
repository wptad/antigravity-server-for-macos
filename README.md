# Antigravity Server for macOS

A Docker-based workaround for using [Google Antigravity](https://ai.google.dev/antigravity) on Apple Silicon Macs via Remote SSH.

## Problem

Google Antigravity currently doesn't support macOS (darwin-arm64 binary is missing), which means you can't use Remote SSH to connect to an Apple Silicon Mac. When attempting to connect, you'll encounter errors like:

- "macOS isn't supported"
- "darwin-arm binary missing"
- 404 errors when downloading the server binary

See the original discussion: [[BUG] Remote SSH to Apple Silicon Mac fails - darwin-arm binary missing](https://discuss.ai.google.dev/t/bug-remote-ssh-to-apple-silicon-mac-fails-darwin-arm-binary-missing-v1-11-9/110864/38)

## Solution

This project provides a simple workaround: run a Linux Docker container on your Mac that acts as a bridge. Since Antigravity requires a Linux host, the Docker container provides that Linux environment while still allowing you to edit files directly on your Mac's drive through volume mounting.

## Quick Start

### Option 1: Use Pre-built Image (Recommended)

1. Create a `docker-compose.yml` file:

```yaml
services:
  antigravity-server-for-macos:
    image: ghcr.io/wptad/antigravity-server-for-macos:latest
    container_name: antigravity-server-for-macos
    ports:
      - "2222:22"
    volumes:
      # Your workspace - change this to your project path
      - "/Users/YOUR_USERNAME/workspace:/workspace"
      # Your SSH authorized_keys for passwordless login
      - "/Users/YOUR_USERNAME/.ssh/authorized_keys:/tmp/authorized_keys:ro"
    restart: unless-stopped
```

2. Start the container:

```bash
docker-compose up -d
```

3. Connect via SSH:

```bash
ssh -p 2222 root@localhost
```

### Option 2: Build Locally

1. Clone this repository:

```bash
git clone https://github.com/wptad/antigravity-server-for-macos.git
cd antigravity-server-for-macos
```

2. Build and run:

```bash
docker build -t antigravity-server-for-macos .
docker-compose up -d
```

## Usage with Antigravity

1. In your IDE with Antigravity, configure Remote SSH connection:
   - Host: `your-mac-ip` (or `localhost` if on the same machine)
   - Port: `2222`
   - User: `root`

2. Once connected, open the `/workspace` folder to access your code.

## Configuration

### Volumes

| Host Path | Container Path | Description |
|-----------|----------------|-------------|
| `/Users/YOUR_USERNAME/workspace` | `/workspace` | Your project files |
| `/Users/YOUR_USERNAME/.ssh/authorized_keys` | `/tmp/authorized_keys` | SSH public keys for authentication |

### Ports

| Host Port | Container Port | Description |
|-----------|----------------|-------------|
| 2222 | 22 | SSH access |

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│                    Apple Silicon Mac                     │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │              Docker Container (Linux)             │   │
│  │                                                   │   │
│  │  ┌─────────────┐    ┌─────────────────────────┐  │   │
│  │  │  SSH Server │◄───│  Antigravity connects   │  │   │
│  │  │  (port 22)  │    │  via Remote SSH         │  │   │
│  │  └─────────────┘    └─────────────────────────┘  │   │
│  │         │                                        │   │
│  │         ▼                                        │   │
│  │  ┌─────────────┐                                 │   │
│  │  │  /workspace │ ◄── Volume mount ──┐           │   │
│  │  └─────────────┘                    │           │   │
│  └──────────────────────────────────────│───────────┘   │
│                                         │               │
│  ┌──────────────────────────────────────▼───────────┐   │
│  │           Mac Filesystem                          │   │
│  │           /Users/xxx/workspace                    │   │
│  └───────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## License

MIT
