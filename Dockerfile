FROM golang:alpine as builder

RUN apk --no-cache add git \
 \
 && go get -v golang.org/x/crypto/bcrypt \
 && go get -v gopkg.in/yaml.v2 \
 \
 && go get -v github.com/MarvAmBass/webdav \
 && cd $GOPATH/src/github.com/MarvAmBass/webdav/cmd/webdav \
 && go build

FROM alpine:latest

COPY webdav.conf /etc/webdav.conf
COPY --from=builder /go/src/github.com/MarvAmBass/webdav/cmd/webdav/webdav /bin/webdav

RUN mkdir /shares \
 && echo "#!/bin/sh" > /bin/entrypoint.sh \
 && echo 'echo "$USER_CONFIG" >> /etc/webdav.conf' >> /bin/entrypoint.sh \
 && echo "exec /bin/webdav --config /etc/webdav.conf" >> /bin/entrypoint.sh \
 && chmod a+x /bin/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/bin/entrypoint.sh"]
