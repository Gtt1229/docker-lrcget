# docker-lrcget

Docker container for LRCGET

The LRCGET version is checked nightly and the docker image is built accordingly.

The GUI of the application is accessed through a modern web browser (no installation or configuration needed on client side) or via any VNC client.

---

[![LRCGET logo](https://raw.githubusercontent.com/tranxuanthang/lrcget/main/src-tauri/icons/128x128.png)](https://github.com/tranxuanthang/lrcget)

[LRCGET](https://github.com/tranxuanthang/lrcget)

LRCGET is a utility for mass-downloading LRC synced lyrics for your offline music library.

---

This container is based on the absolutely fantastic [jlesage/baseimage-gui](https://hub.docker.com/r/jlesage/baseimage-gui) and based on [mikenye/picard](https://github.com/mikenye/docker-picard)'s Docker container implementation of MusicBrainz Picard. All the hard work has been done by them, and I shamelessly copied [mikenye/picard](https://github.com/mikenye/docker-picard)'s README who copied their README.md. I've cut the README.md down quite a bit, for advanced usage I suggest you check out the [README](https://github.com/jlesage/docker-handbrake/blob/master/README.md) from [jlesage/baseimage-gui](https://hub.docker.com/r/jlesage/baseimage-gui).

---

# ⚠️ NOTE ABOUT AUDIO ⚠️

The container supports audio via the web UI; however, audio is not for listening purposes as the quality is heavily degraded. **It should be used only to confirm lyrics are matching and syncing**.

---

## Table of Contents

   * [Quick Start](#quick-start)
   * [Usage](#usage)
      * [Environment Variables](#environment-variables)
      * [Data Volumes](#data-volumes)
      * [Ports](#ports)
      * [Changing Parameters of a Running Container](#changing-parameters-of-a-running-container)
   * [Docker Compose File](#docker-compose-file)
   * [Docker Image Update](#docker-image-update)
   * [User/Group IDs](#usergroup-ids)
   * [Accessing the GUI](#accessing-the-gui)
   * [Security](#security)
      * [Certificates](#certificates)
      * [VNC Password](#vnc-password)
   * [Shell Access](#shell-access)
   * [Building](#building)

---

## Quick Start

**NOTE**: The Docker command provided in this quick start is given as an example and parameters should be adjusted to your needs.

Launch the LRCGET docker container with the following command:

```shell
docker run -d \
    --name=docker-lrcget \
    -p 5800:5800 \
    -v /docker/appdata/lrcget:/config:rw \
    -v /path/to/music:/music:rw \
    gtt1229/docker-lrcget
```

Where:

* `/docker/appdata/lrcget`: This is where the application stores its configuration, log and any files needing persistency.
* `/path/to/music`: This location contains music files for LRCGET to operate on.

Browse to `http://your-host-ip:5800` to access the LRCGET GUI. Your music will be located under `/music`.

---

## Usage

```shell
docker run [-d] \
    --name=docker-lrcget \
    [-e <VARIABLE_NAME>=<VALUE>]... \
    [-v <HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]]... \
    [-p <HOST_PORT>:<CONTAINER_PORT>]... \
    gtt1229/docker-lrcget
```

| Parameter | Description |
|-----------|-------------|
| -d        | Run the container in background. If not set, the container runs in foreground. |
| -e        | Pass an environment variable to the container. See the [Environment Variables](#environment-variables) section for more details. |
| -v        | Set a volume mapping (allows to share a folder/file between the host and the container). See the [Data Volumes](#data-volumes) section for more details. |
| -p        | Set a network port mapping (exposes an internal container port to the host). See the [Ports](#ports) section for more details. |

### Environment Variables

To customize some properties of the container, the following environment variables can be passed via the `-e` parameter (one for each variable). Value of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`USER_ID`| ID of the user the application runs as. See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`GROUP_ID`| ID of the group the application runs as. See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`SUP_GROUP_IDS`| Comma-separated list of supplementary group IDs of the application. | (unset) |
|`UMASK`| Mask that controls how file permissions are set for newly created files. The value of the mask is in octal notation. By default, this variable is not set and the default umask of `022` is used, meaning that newly created files are readable by everyone, but only writable by the owner. See the following online umask calculator: http://wintelguy.com/umask-calc.pl | (unset) |
|`TZ`| [TimeZone] of the container. Timezone can also be set by mapping `/etc/localtime` between the host and the container. | `Etc/UTC` |
|`KEEP_APP_RUNNING`| When set to `1`, the application will be automatically restarted if it crashes or if user quits it. | `1` |
|`APP_NICENESS`| Priority at which the application should run. A niceness value of -20 is the highest priority and 19 is the lowest priority. By default, niceness is not set, meaning that the default niceness of 0 is used. **NOTE**: A negative niceness (priority increase) requires additional permissions. In this case, the container should be run with the docker option `--cap-add=SYS_NICE`. | (unset) |
|`CLEAN_TMP_DIR`| When set to `1`, all files in the `/tmp` directory are deleted during the container startup. | `1` |
|`DISPLAY_WIDTH`| Width (in pixels) of the application's window. | `1280` |
|`DISPLAY_HEIGHT`| Height (in pixels) of the application's window. | `768` |
|`SECURE_CONNECTION`| When set to `1`, an encrypted connection is used to access the application's GUI (either via web browser or VNC client). See the [Security](#security) section for more details. | `0` |
|`VNC_PASSWORD`| Password needed to connect to the application's GUI. See the [VNC Password](#vnc-password) section for more details. | (unset) |
|`X11VNC_EXTRA_OPTS`| Extra options to pass to the x11vnc server running in the Docker container. **WARNING**: For advanced users. Do not use unless you know what you are doing. | (unset) |
|`ENABLE_CJK_FONT`| When set to `1`, open source computer font `WenQuanYi Zen Hei` is installed. This font contains a large range of Chinese/Japanese/Korean characters. | `0` |

### Data Volumes

The following table describes data volumes used by the container. The mappings are set via the `-v` parameter. Each mapping is specified with the following format: `<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
|`/config`| rw | This is where the application stores its configuration, log and any files needing persistency. |
|`/music`| rw | This location contains files from your host that need to be accessible by the application. LRCGET will download lyrics for music files in this directory. |

### Ports

Here is the list of ports used by the container. They can be mapped to the host via the `-p` parameter (one per port mapping). Each mapping is defined in the following format: `<HOST_PORT>:<CONTAINER_PORT>`. The port number inside the container cannot be changed, but you are free to use any port on the host side.

| Port | Mapping to host | Description |
|------|-----------------|-------------|
| 5800 | Mandatory | Port used to access the application's GUI via the web interface. |
| 5900 | Optional | Port used to access the application's GUI via the VNC protocol. Optional if no VNC client is used. |

### Changing Parameters of a Running Container

As seen, environment variables, volume mappings and port mappings are specified while creating the container.

The following steps describe the method used to add, remove or update parameter(s) of an existing container. The generic idea is to destroy and re-create the container:

1. Stop the container (if it is running):

```shell
docker stop docker-lrcget
```

2. Remove the container:

```shell
docker rm docker-lrcget
```

3. Create/start the container using the `docker run` command, by adjusting parameters as needed.

**NOTE**: Since all application's data is saved under the `/config` container folder, destroying and re-creating a container is not a problem: nothing is lost and the application comes back with the same state (as long as the mapping of the `/config` folder remains the same).

---

## Docker Compose File

Here is an example of a `docker-compose.yml` file that can be used with [Docker Compose](https://docs.docker.com/compose/overview/).

Make sure to adjust according to your needs. Note that only mandatory network ports are part of the example.

```yaml
services:
  docker-lrcget:
    image: gtt1229/docker-lrcget:latest
    container_name: docker-lrcget
    restart: unless-stopped
    ports:
      - "5800:5800"
    volumes:
      - "./docker/config:/config:rw"
      - "/path/to/music:/music:rw"
    environment:
      - USER_ID=1000
      - GROUP_ID=1000
      - TZ=America/New_York
    shm_size: '2gb'
```

---

## Docker Image Update

If the system on which the container runs doesn't provide a way to easily update the Docker image, the following steps can be followed:

1. Fetch the latest image:

```shell
docker pull gtt1229/docker-lrcget
```

2. Stop the container:

```shell
docker stop docker-lrcget
```

3. Remove the container:

```shell
docker rm docker-lrcget
```

4. Start the container using the `docker run` command.

---

## User/Group IDs

When using data volumes (`-v` flags), permissions issues can occur between the host and the container. For example, the user within the container may not exist on the host. This could prevent the host from properly accessing files and folders on the shared volume.

To avoid any problem, you can specify the user the application should run as.

This is done by passing the user ID and group ID to the container via the `USER_ID` and `GROUP_ID` environment variables.

To find the right IDs to use, issue the following command on the host, with the user owning the data volume on the host:

```shell
id <username>
```

Which gives an output like this one:

```text
uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),4(adm),24(cdrom),27(sudo),46(plugdev),113(lpadmin)
```

The value of `uid` (user ID) and `gid` (group ID) are the ones that you should be given the container.

---

## Accessing the GUI

Assuming that container's ports are mapped to the same host's ports, the graphical interface of the application can be accessed via:

* A web browser:

```text
http://<HOST IP ADDR>:5800
```

* Any VNC client:

```text
<HOST IP ADDR>:5900
```

---

## Security

By default, access to the application's GUI is done over an unencrypted connection (HTTP or VNC).

Secure connection can be enabled via the `SECURE_CONNECTION` environment variable. See the [Environment Variables](#environment-variables) section for more details on how to set an environment variable.

When enabled, application's GUI is performed over an HTTPs connection when accessed with a browser. All HTTP accesses are automatically redirected to HTTPs.

When using a VNC client, the VNC connection is performed over SSL. Note that few VNC clients support this method. [SSVNC] is one of them.

[SSVNC]: http://www.karlrunge.com/x11vnc/ssvnc.html

### Certificates

Here are the certificate files needed by the container. By default, when they are missing, self-signed certificates are generated and used. All files have PEM encoded, x509 certificates.

| Container Path                  | Purpose                    | Content |
|---------------------------------|----------------------------|---------|
|`/config/certs/vnc-server.pem`   |VNC connection encryption.  |VNC server's private key and certificate, bundled with any root and intermediate certificates.|
|`/config/certs/web-privkey.pem`  |HTTPs connection encryption.|Web server's private key.|
|`/config/certs/web-fullchain.pem`|HTTPs connection encryption.|Web server's certificate, bundled with any root and intermediate certificates.|

**NOTE**: To prevent any certificate validity warnings/errors from the browser or VNC client, make sure to supply your own valid certificates.

**NOTE**: Certificate files are monitored and relevant daemons are automatically restarted when changes are detected.

### VNC Password

To restrict access to your application, a password can be specified. This can be done via two methods:

* By using the `VNC_PASSWORD` environment variable.
* By creating a `.vncpass_clear` file at the root of the `/config` volume. This file should contain the password in clear-text. During the container startup, content of the file is obfuscated and moved to `.vncpass`.

The level of security provided by the VNC password depends on two things:

* The type of communication channel (encrypted/unencrypted).
* How secure access to the host is.

When using a VNC password, it is highly desirable to enable the secure connection to prevent sending the password in clear over an unencrypted channel.

**ATTENTION**: Password is limited to 8 characters. This limitation comes from the Remote Framebuffer Protocol [RFC](https://tools.ietf.org/html/rfc6143) (see section [7.2.2](https://tools.ietf.org/html/rfc6143#section-7.2.2)). Any characters beyond the limit are ignored.

---

## Shell Access

To get shell access to the running container, execute the following command:

```shell
docker exec -ti docker-lrcget sh
```

---

## Building

To build the Docker image yourself:

```shell
docker build -t docker-lrcget:latest .
```

To build with a specific LRCGET version:

```shell
docker build --build-arg LRCGET_VERSION=1.0.2 -t docker-lrcget:latest .
```

Check the [LRCGET releases page](https://github.com/tranxuanthang/lrcget/releases) for available versions.

---

## Support

For issues specific to this Docker container, please open an issue on GitHub.

For LRCGET application issues, please visit the [LRCGET repository](https://github.com/tranxuanthang/lrcget).

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Your music library accessible on the host system

### Basic Setup

1. **Clone or navigate to the repository**:
   ```bash
   cd /path/to/lrcget
   ```

2. **Edit the docker-compose.yml file**:
   Update the music volume path to point to your music library:
   ```yaml
   volumes:
     - /path/to/your/music:/music:rw
   ```

3. **Build and start the container**:
   ```bash
   docker-compose up -d
   ```

4. **Access LRCGET**:
   Open your browser and navigate to:
   ```
   http://localhost:5800
   ```

That's it! LRCGET should now be running in your browser.

## Detailed Configuration

### Environment Variables

Configure the container behavior by setting environment variables in [docker-compose.yml](docker-compose.yml):

| Variable | Description | Default |
|----------|-------------|---------|
| `USER_ID` | ID of the user the application runs as | `1000` |
| `GROUP_ID` | ID of the group the application runs as | `1000` |
| `DISPLAY_WIDTH` | Width of the application window in pixels | `1280` |
| `DISPLAY_HEIGHT` | Height of the application window in pixels | `768` |
| `KEEP_APP_RUNNING` | Auto-restart if application crashes (1=yes, 0=no) | `1` |
| `TZ` | Container timezone | `America/New_York` |
| `VNC_PASSWORD` | Password for VNC access (max 8 chars) | (none) |
| `SECURE_CONNECTION` | Enable HTTPS/SSL (1=yes, 0=no) | `0` |
| `ENABLE_CJK_FONT` | Install Chinese/Japanese/Korean fonts | `0` |

### Ports

| Port | Purpose | Required |
|------|---------|----------|
| 5800 | Web interface (HTTP/HTTPS) | ✅ Yes |
| 5900 | VNC protocol access | ⚪ Optional |

### Volumes

| Container Path | Purpose | Permissions |
|----------------|---------|-------------|
| `/config` | Application configuration and data | Read/Write |
| `/music` | Your music library | Read/Write |

### Finding Your User/Group IDs

To avoid permission issues with volume mounts, set the correct USER_ID and GROUP_ID:

```bash
id $(whoami)
```

Output example:
```
uid=1000(username) gid=1000(username) groups=...
```

Use the `uid` value for `USER_ID` and `gid` value for `GROUP_ID`.

## Usage Examples

### Docker Compose (Recommended)

Create or edit `docker-compose.yml`:

```yaml
version: '3.8'

services:
  docker-lrcget:
    image: docker-lrcget:latest
    build:
      context: .
      dockerfile: Dockerfile
    container_name: docker-lrcget
    restart: unless-stopped
    ports:
      - "5800:5800"
      - "5900:5900"
    environment:
      - USER_ID=1000
      - GROUP_ID=1000
      - DISPLAY_WIDTH=1920
      - DISPLAY_HEIGHT=1080
      - TZ=America/New_York
      - VNC_PASSWORD=mypass123
    volumes:
      - ./docker/config:/config:rw
      - /mnt/music:/music:rw
    devices:
      - /dev/snd:/dev/snd
    shm_size: '2gb'
```

Then run:
```bash
docker-compose up -d
```

### Docker Run Command

```bash
# Build the image
docker build -t docker-lrcget:latest .

# Run the container
docker run -d \
  --name=docker-lrcget \
  -p 5800:5800 \
  -p 5900:5900 \
  -e USER_ID=1000 \
  -e GROUP_ID=1000 \
  -e DISPLAY_WIDTH=1280 \
  -e DISPLAY_HEIGHT=768 \
  -e KEEP_APP_RUNNING=1 \
  -e TZ=America/New_York \
  -v $(pwd)/docker/config:/config:rw \
  -v /path/to/music:/music:rw \
  --device /dev/snd:/dev/snd \
  --shm-size 2g \
  docker-lrcget:latest
```

### Building with a Specific Version

To use a different LRCGET version:

```bash
docker build \
  --build-arg LRCGET_VERSION=1.0.2 \
  -t docker-lrcget:1.0.2 \
  .
```

Check [LRCGET releases](https://github.com/tranxuanthang/lrcget/releases) for available versions.

## Accessing the Application

### Via Web Browser (Recommended)

1. Open your web browser
2. Navigate to: `http://<host-ip>:5800`
3. The LRCGET interface will appear in your browser

### Via VNC Client

If you prefer using a VNC client:

1. Use any VNC client (TigerVNC, RealVNC, TightVNC, etc.)
2. Connect to: `<host-ip>:5900`
3. Enter the VNC password if configured

## Security

### Enabling HTTPS

To enable secure HTTPS access:

1. Set environment variable:
   ```yaml
   - SECURE_CONNECTION=1
   ```

2. Provide your own certificates (recommended) or use auto-generated self-signed certificates:
   - `/config/certs/web-privkey.pem` - Web server's private key
   - `/config/certs/web-fullchain.pem` - Web server's certificate bundle
   - `/config/certs/vnc-server.pem` - VNC server's private key and certificate

### Setting a VNC Password

Protect access to your application:

**Method 1: Environment Variable**
```yaml
environment:
  - VNC_PASSWORD=yourpass
```

**Method 2: Password File**
Create a file at `/config/.vncpass_clear` with your password in plain text. It will be automatically encrypted on container startup.

⚠️ **Note**: VNC passwords are limited to 8 characters due to the VNC protocol specification.

## Audio Support

The container includes full audio support through PulseAudio:

- Ensure `/dev/snd` device is passed through (included in examples)
- Audio will play through the browser when using the web interface
- For VNC clients, audio depends on the client's capabilities

## Troubleshooting

### Container won't start

Check logs:
```bash
docker-compose logs -f docker-lrcget
```

### Permission issues with music files

Ensure USER_ID and GROUP_ID match your host user:
```bash
id $(whoami)
```

Update docker-compose.yml accordingly.

### Application crashes or closes

Ensure `KEEP_APP_RUNNING=1` is set to auto-restart the application.

### No audio

1. Verify `/dev/snd` device is accessible:
   ```bash
   ls -l /dev/snd
   ```

2. Check PulseAudio is running in container:
   ```bash
   docker exec -it docker-lrcget ps aux | grep pulse
   ```

### Can't access on port 5800

1. Check if container is running:
   ```bash
   docker ps
   ```

2. Verify port isn't in use:
   ```bash
   netstat -tulpn | grep 5800
   ```

3. Check firewall rules

## Updating the Container

To update to the latest version:

```bash
# Stop the container
docker-compose down

# Rebuild the image
docker-compose build --no-cache

# Start the container
docker-compose up -d
```

## Advanced Configuration

### Custom Display Resolution

```yaml
environment:
  - DISPLAY_WIDTH=1920
  - DISPLAY_HEIGHT=1080
```

### Timezone Configuration

**Method 1: Environment Variable**
```yaml
environment:
  - TZ=Europe/London
```

**Method 2: Volume Mount**
```yaml
volumes:
  - /etc/localtime:/etc/localtime:ro
```

### Running with Higher Priority

To run with elevated priority (requires additional permissions):

```yaml
environment:
  - APP_NICENESS=-10
cap_add:
  - SYS_NICE
```

## Architecture

This Docker setup uses:
- **Base Image**: [jlesage/baseimage-gui](https://hub.docker.com/r/jlesage/baseimage-gui) - Provides VNC/noVNC infrastructure
- **LRCGET Binary**: Official prebuilt AppImage from [GitHub releases](https://github.com/tranxuanthang/lrcget/releases)
- **Display Server**: X11 with Xvfb
- **VNC Server**: x11vnc
- **Web Access**: noVNC (HTML5 VNC client)
- **Window Manager**: Openbox
- **Audio**: PulseAudio

## Credits

This Docker configuration is inspired by and based on the excellent work from:
- [jlesage/baseimage-gui](https://github.com/jlesage/docker-baseimage-gui) - Base GUI container framework
- [mikenye/docker-picard](https://github.com/mikenye/docker-picard) - Reference implementation

## Support

For issues specific to:
- **LRCGET application**: Report on the main LRCGET repository
- **Docker container/VNC access**: Open an issue with Docker-specific details

## License

This Docker configuration follows the same license as the main LRCGET project.
