FROM alpine:3.3
RUN apk add --no-cache bash
COPY . /pipespect
ENTRYPOINT ["/pipespect/pipespect.sh"]
