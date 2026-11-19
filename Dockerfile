FROM golang:1.27.0-alpine AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -o /out/server ./cmd/server
RUN CGO_ENABLED=0 go build -trimpath -o /out/attackerlab ./cmd/attackerlab

FROM alpine:3.22
RUN apk add --no-cache ca-certificates && addgroup -S bearly && adduser -S -G bearly bearly
WORKDIR /app
COPY --from=build /out/server server
COPY --from=build /out/attackerlab attackerlab
COPY --from=build /app/attacker-lab/ attacker-lab/
COPY --from=build /app/web/ web/
COPY --chown=bearly:bearly --from=build /app/data/uploads/mystery-shack-tax-exemption.pdf data/uploads/mystery-shack-tax-exemption.pdf
USER bearly 
CMD ["./server"]
