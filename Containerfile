# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /build_files
COPY system_files /files


FROM ghcr.io/ublue-os/bazzite:latest

RUN \
  --mount=type=bind,from=ctx,source=/,target=/run/context \
  --mount=type=tmpfs,dst=/tmp \
  mkdir -p /var/roothome && \
  /run/context/build_files/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
