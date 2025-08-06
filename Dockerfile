FROM golang:1.21 as builder
WORKDIR /app
COPY go-app/ .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

FROM alpine
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]