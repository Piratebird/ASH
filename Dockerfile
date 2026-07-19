FROM alpine:latest

RUN apk add --no-cache bash lighttpd curl procps iproute2 gettext

WORKDIR /app
COPY . .

EXPOSE 8080
CMD ["bash", "/app/server.sh"]
