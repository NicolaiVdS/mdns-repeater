#!/bin/sh
set -e

# Create /run/dbus directory if it doesn't exist
mkdir -p /run/dbus
chmod 755 /run/dbus

# Start dbus system bus daemon
dbus-daemon --system --nofork &

# Start avahi daemon
avahi-daemon --no-chroot &

# Check if INTERFACES is set, otherwise use default interfaces
if [ -z "$INTERFACES" ]; then
    echo "Warning: INTERFACES environment variable not set, using default: eno1 docker0"
    INTERFACES="eno1 docker0"
fi

# Convert INTERFACES to array and pass to mdns-repeater
exec /usr/local/bin/mdns-repeater -f $INTERFACES
