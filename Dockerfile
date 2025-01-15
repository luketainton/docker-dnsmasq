FROM alpine:3.21 AS build
LABEL maintainer="Luke Tainton <luke@tainton.uk>"

FROM build AS webproc
ENV WEBPROCVERSION 0.4.0
ENV WEBPROCURL https://github.com/jpillora/webproc/releases/download/v$WEBPROCVERSION/webproc_"$WEBPROCVERSION"_linux_amd64.gz
RUN apk add --no-cache curl && \
    curl -sL "$WEBPROCURL" | gzip -d - > /usr/local/bin/webproc && \
    chmod +x /usr/local/bin/webproc

FROM build AS dnsmasq
RUN apk --no-cache add dnsmasq=2.90-r3
COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc
ENTRYPOINT ["webproc","-o","restart","-c","/etc/dnsmasq.conf","-c","/etc/hosts","-c","/etc/resolv.conf","--","dnsmasq","-k","--log-facility=-"]
EXPOSE 53/udp 8080/tcp
