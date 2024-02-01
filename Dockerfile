# ========================================================
# Stage: Builder with Air Integration for Live Reloading
# ========================================================
FROM golang:1.21-alpine AS builder

# Set working directory
WORKDIR /app

# Install dependencies in a single layer
RUN apk --no-cache --update add build-base gcc wget unzip git

# Install Air for live reloading
RUN go install github.com/cosmtrek/air@latest

# Copy the source code
COPY . .

# Set environment variables
ENV CGO_ENABLED=1 \
    CGO_CFLAGS="-D_LARGEFILE64_SOURCE" \
    GO111MODULE=on

# Build the application - comment out for live reloading
# RUN go build -o build/x-ui main.go

# Execute Docker initialization script
ARG TARGETARCH
RUN ./DockerInit.sh "$TARGETARCH"

# ========================================================
# Stage: Final Image of 3x-ui
# ========================================================
FROM alpine

# Set environment variable and working directory
ENV TZ=Asia/Tehran
WORKDIR /app

# Install packages
RUN apk add --no-cache --update ca-certificates tzdata fail2ban && \
    # Configure fail2ban
    rm -f /etc/fail2ban/jail.d/alpine-ssh.conf && \
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local && \
    sed -i "s/^\[ssh\]$/&\nenabled = false/" /etc/fail2ban/jail.local && \
    sed -i "s/^\[sshd\]$/&\nenabled = false/" /etc/fail2ban/jail.local && \
    sed -i "s/#allowipv6 = auto/allowipv6 = auto/g" /etc/fail2ban/fail2ban.conf

# Copy necessary files from builder stage
COPY --from=builder /app/build/ /app/
COPY --from=builder /app/DockerEntrypoint.sh /app/
COPY --from=builder /app/x-ui.sh /usr/bin/x-ui
COPY --from=builder /go/bin/air /usr/bin/air

# Set permissions
RUN chmod +x /app/DockerEntrypoint.sh /app/x-ui /usr/bin/x-ui

# Define volume and entrypoint
VOLUME [ "/etc/x-ui" ]
ENTRYPOINT [ "/app/DockerEntrypoint.sh" ]
