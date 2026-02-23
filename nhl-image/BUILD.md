# How to build the NHL Led Scoreboard Raspberry Pi OS Image Locally

The build process for the image has moved from Packer to a bash script (`bootstrap-local.sh`) that is executed inside a privileged Docker container.

This process enables anyone, including Windows and **MacOS** users, to build the image locally without needing a dedicated Linux machine.

## Prerequisites

* **Docker Installed**: You need Docker Desktop, OrbStack (recommended for MacOS), or a native Docker installation.
* Ensure your Docker environment supports running privileged containers and loopback devices.

## Build Instructions

1. **Navigate to the `nhl-image` directory:**
   Open a terminal and make sure you are in the `nhl-image` directory of this repository.
   ```bash
   cd nhl-image
   ```

2. **Start the Builder Container:**
   We use Docker Compose to spin up a Debian Bookworm container with the required privileges.
   ```bash
   docker compose -f dietpi-compose.yml up -d
   ```

3. **Run the Build Script:**
   Execute the `bootstrap-local.sh` script inside the running container. This script will download the base DietPi image, expand it, install dependencies via Ansible, shrink it, and compress it.
   ```bash
   docker compose -f dietpi-compose.yml exec builder bash bootstrap-local.sh
   ```

4. **Cleanup:**
   Once the build completes successfully (or if it fails and you want to clean up), you can tear down the builder container.
   ```bash
   docker compose -f dietpi-compose.yml down
   ```

## Output

After a successful run, your newly created image will be located in the `nhl-image` directory, named `nhl-scoreboard-dietpi.img.xz`. You can flash this directly to an SD card using tools like Balena Etcher or the Raspberry Pi Imager.

## Caching / Variables

If you'd like to use a proxy for APT packages, PyPI, or set specific Ansible variables during the build, you can create a `user-config` file in the `nhl-image` directory. `bootstrap-local.sh` reads this file to inject environment variables before executing Ansible.
