FROM golang:1.27 AS build

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app .

FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=build /app /app

EXPOSE 3000
USER nonroot:nonroot

ENTRYPOINT [ "/app" ]
