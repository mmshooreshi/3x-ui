# Start from the official Golang image to create a build artifact.
FROM golang:1.21-alpine as builder

WORKDIR /app

# Install system dependencies
RUN apk add --no-cache git

# Copy go mod and sum files 
COPY go.mod go.sum ./

# Download all dependencies.
RUN go mod download

# Copy the source code and .air.toml file.
COPY . .

# Install Air for hot reloading
# Ensure air is installed in a globally accessible location
RUN go install github.com/cosmtrek/air@latest

# Verify that air is installed
RUN which air

# This stage builds the application.
FROM golang:1.21-alpine

WORKDIR /app

# Copy the application files from the builder stage.
COPY --from=builder /app /app

# Copy the air binary from the builder stage.
# The path should be adjusted to wherever `which air` reports it to be.
# COPY --from=builder /go/bin/air /bin/air

# Copy .air.toml from the builder stage.
# Ensure this file exists in your project directory.
COPY --from=builder /app/.air.toml /.air.toml

CMD ["air"]
