# ステージ１
FROM golang:1.23.2-alpine3.19 AS builder
WORKDIR /app
COPY . .
RUN go mod download && go build -o main /app/main.go

# ステージ２
FROM alpine:3.19
WORKDIR /app
COPY --from=builder /app/main .

CMD ["sh", "-c", "/app/main"]

# 動作確認用のコマンド
# CMD ["sh", "-c", "/app/main & tail -f /dev/null"] 