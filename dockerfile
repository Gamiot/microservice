FROM golang:alpine AS builder

# Install git + SSL ca certificates.
# Git is required for fetching the dependencies.
# Ca-certificates is required to call HTTPS endpoints.
RUN apk update && apk add --no-cache git ca-certificates && update-ca-certificates

# Create appuser
RUN adduser -D -g '' appuser
WORKDIR $GOPATH/src/mypackage/myapp/
COPY . .
# Fetch dependencies.
# Using go mod with go 1.11
RUN go mod download
RUN go mod verify
# Build the binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /go/bin/app
############################
# STEP 2 build a small image
############################
FROM scratch
# Import from builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy our static executable
COPY --from=builder /go/bin/app /go/bin/app
# Use an unprivileged user.
USER appuser
# Run the hello binary.
ENTRYPOINT ["/go/bin/app"]