# Start from the official Golang image to create a build artifact.
FROM golang:1.21.6-alpine as builder

WORKDIR /app

# Install system dependencies
RUN apk add --no-cache git

# Copy go mod and sum files 
COPY go.mod go.sum ./

# Download all dependencies.
RUN go mod download

# Copy the source code.
COPY . .

# Install Air for hot reloading
RUN go get -u github.com/cosmtrek/air

# This stage builds the application.
FROM golang:1.21.6-alpine

WORKDIR /app

# Copy the binary and other necessary files from the builder stage.
COPY --from=builder /app /app
COPY --from=builder /go/bin/air /bin/air
COPY --from=builder /app/.air.toml /.air.toml

CMD ["air"]
