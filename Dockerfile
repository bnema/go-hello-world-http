# Start from scratch
FROM alpine:latest

ARG ARCH

# Copy the pre-built binary for the specific architecture
COPY dist/helloworld-linux-${ARCH} /helloworld

# Set the entrypoint
ENTRYPOINT ["/hellworld"]
