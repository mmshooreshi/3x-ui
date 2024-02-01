# Start from the official Golang image to create a build artifact.
FROM golang:latest as builder

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
FROM golang:latest
RUN go get -u github.com/cosmtrek/air
WORKDIR /app
ENTRYPOINT ["air"]
