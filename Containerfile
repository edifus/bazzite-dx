# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /build
COPY system_files /system


FROM ghcr.io/ublue-os/bazzite:latest

RUN \
  --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  mkdir -p /var/roothome && \
  /ctx/build/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
