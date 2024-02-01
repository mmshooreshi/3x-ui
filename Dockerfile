# Start from the latest golang base image
FROM golang:1.21.6

# Update and install necessary packages
RUN apt-get update && apt-get install -y curl

# Install any additional dependencies if required

# Install Air for live reloading
RUN go install github.com/cosmtrek/air@latest

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the Go modules and sum files
COPY go.mod go.sum ./

# Download all dependencies.
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

# Copy the Air configuration file
COPY .air.toml ./

# Expose the port that your app runs on
EXPOSE 8080

# Command to run Air for live reloading
CMD ["air"]
