FROM alpine:3.11 as build
LABEL maintainer="David Chidell (dchidell@cisco.com)"

FROM build as webproc
ENV WEBPROC_VERSION 0.3.0
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/v${WEBPROC_VERSION}/webproc_${WEBPROC_VERSION}_linux_amd64.gz
RUN apk add --no-cache curl
RUN curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc
RUN chmod +x /usr/local/bin/webproc

FROM build as dnsmasq
RUN apk --no-cache add dnsmasq
COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc
ENTRYPOINT ["webproc","--on-exit","restart","-c","/etc/dnsmasq.conf,/etc/hosts,/etc/resolv.conf","--","dnsmasq","-k","--log-facility=-"]
EXPOSE 53/udp 8080
