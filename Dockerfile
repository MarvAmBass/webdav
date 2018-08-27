FROM golang as builder

ENV GOOS=linux GOARCH=386

RUN go get -v golang.org/x/crypto/bcrypt \
 && go get -v gopkg.in/yaml.v2 \
 \
 && go get -v github.com/MarvAmBass/webdav \
 && cd $GOPATH/src/github.com/MarvAmBass/webdav/cmd/webdav \
 && go build

FROM busybox:latest

COPY --from=builder /go/src/github.com/MarvAmBass/webdav/cmd/webdav/webdav /webdav

RUN mkdir /shares \
 \
 && echo "scope: /shares" > /webdav.conf \
 && echo "address: 0.0.0.0" >> /webdav.conf \
 && echo "port: 8080" >> /webdav.conf \
 \
 && echo "#!/bin/sh" > /entrypoint.sh \
 && echo 'echo "$USER_CONFIG" >> /webdav.conf' >> /entrypoint.sh \
 && echo "/webdav --config /webdav.conf" >> /entrypoint.sh \
 && chmod a+x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
