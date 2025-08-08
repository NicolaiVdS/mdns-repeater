# mDNS Repeater

A lightweight Docker image for repeating mDNS (Multicast DNS) traffic between network interfaces, enabling service discovery (e.g., `ble_tracker.local`) across Docker networks and physical interfaces. This is useful for environments like Home Assistant and ESPHome, where devices need to resolve mDNS names across isolated networks.

## Features

- Built from [geekman's `mdns-repeater.c`](https://github.com/geekman/mdns-repeater).
- Lightweight Alpine Linux base image (~10MB).
- Configurable via environment variables to specify network interfaces.
- Ideal for bridging Docker networks (e.g., `nginx-proxy`) with host interfaces (e.g., `eth0`).

## Prerequisites

- Docker and Docker Compose installed.
- A Docker Hub account for pulling/pushing the image.
- Host network interface name (e.g., `eth0`, `wlan0`) known. Check with `ip link`.
- Port 5353/UDP open on the host for mDNS traffic.

## Usage

### Docker Run

Run the mDNS repeater, specifying the interfaces to bridge:

```bash
docker run -d \
  --name mdns-repeater \
  --network host \
  --privileged \
  -e INTERFACES="eth0 docker0" \
  vdsnicolai/mdns-repeater:latest
```

- `--network host`: Required to access host network interfaces.
- `--privileged`: Allows binding to network interfaces.
- `-e INTERFACES`: Space-separated list of interfaces to bridge (e.g., `eth0 docker0`).

### Docker Compose

Add the mDNS repeater to your `docker-compose.yml`:

```yaml
version: "3.5"
services:
  mdns-repeater:
    container_name: mdns-repeater
    image: vdsnicolai/mdns-repeater:latest
    network_mode: host
    privileged: true
    environment:
      - INTERFACES=eth0 nginx-proxy
    restart: unless-stopped
```

### Testing mDNS Resolution

Test mDNS resolution from another container (e.g., Home Assistant):

```bash
docker exec -it homeassistant bash
apt update && apt install -y avahi-utils
avahi-resolve -n ble_tracker.local
```

## Configuration

- **INTERFACES**: Environment variable specifying space-separated network interfaces to bridge (e.g., `eth0 br-abcdef123456`). Use `docker network inspect <network>` to find Docker network bridge names.
- **Firewall**: Ensure port 5353/UDP is open:
  ```bash
  sudo ufw allow 5353/udp
  ```

## Example Use Case

For a Home Assistant setup with ESPHome devices:

- Bridge the host's `eth0` (physical network with ESPHome devices) and the `nginx-proxy` Docker network.
- Ensure Home Assistant and ESPHome containers can resolve `ble_tracker.local`.

## Troubleshooting

- **"No such device" Error**: Verify interface names with `ip link` or `docker network inspect <network>`.
- **mDNS Not Resolving**: Confirm the device is advertising its mDNS name and is on the same physical network.
- **Logs**: Check container logs with `docker logs mdns-repeater`.

## License

The `mdns-repeater.c` source is licensed under [GPL-3.0](https://github.com/kennylevinsen/mdns-repeater/blob/master/LICENSE).
This repository is licensed under MIT.

## Contributing

Pull requests and issues are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.
