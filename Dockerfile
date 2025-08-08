FROM alpine:latest

# Install build dependencies
RUN apk add --no-cache build-base

# Copy mdns-repeater.c source file
RUN wget -O /mdns-repeater.c https://raw.githubusercontent.com/geekman/mdns-repeater/refs/heads/master/mdns-repeater.c 

# Compile mdns-repeater
RUN gcc /mdns-repeater.c -o /usr/local/bin/mdns-repeater -DHGVERSION=\"1.0.0\"

# Clean up build dependencies to reduce image size
RUN apk del build-base && rm -rf /var/cache/apk/* /mdns-repeater.c

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint to handle INTERFACES environment variable
ENTRYPOINT ["/entrypoint.sh"]
