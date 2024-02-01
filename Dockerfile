# Use the official Golang image as the builder base
FROM golang:latest as builder

# Set the working directory inside the container
WORKDIR /app

# Install git, required for fetching Go dependencies
RUN apk add --no-cache git

# Copy go.mod and go.sum first to leverage Docker cache for dependency download
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code and .air.toml
COPY . .

# Install Air for hot reloading, ensuring it's in a globally accessible location
RUN go install github.com/cosmtrek/air@latest && \
    # Verify air installation
    which air

# Start a new stage from the base Golang image for the final build
FROM golang:latest

# Set the working directory
WORKDIR /app

# Copy compiled assets from the builder stage
COPY --from=builder /app /app
COPY --from=builder /go/bin/air /usr/local/bin

# Set the entrypoint to air for live reloading
ENTRYPOINT ["air"]
