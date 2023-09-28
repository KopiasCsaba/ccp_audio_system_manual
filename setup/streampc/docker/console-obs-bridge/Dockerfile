# syntax=docker/dockerfile:1.2

# Multi stage build file.
#
# buildbase (ubuntu)
# buildbase -> build
# buildbase -> development
#
# prod (alpine)
#


# =========================================================================================================
FROM --platform=$BUILDPLATFORM ubuntu:22.04 AS buildbase

# https://vsupalov.com/buildkit-cache-mount-dockerfile/
RUN rm -f /etc/apt/apt.conf.d/docker-clean # Preventing the base-os to delete apt-cache.

# Just to confirm buildx is working. It would fail around here otherwise.
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN (echo "Running on buildplatform: $BUILDPLATFORM, targetplatform: $TARGETPLATFORM" && arch) > /log


ENV DEBIAN_FRONTEND="noninteractive"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies for compiling & building
# =============================================================================
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update && \
    apt-get install -y --no-install-recommends  curl wget nano tzdata ca-certificates



# =========================================================================================================
FROM buildbase AS prod



# Add user with the same ID as the host (when specifies UID and GID).
# This helps solving file permission issues between host/container.

ARG UID=1000
ARG GID=1000
ARG USER=container

RUN groupadd -g ${GID} ${USER} \
    && useradd -u ${UID} -g ${GID} -d /home/${USER} -s /bin/bash -m ${USER}


COPY oscbridge /home/$USER/app

WORKDIR /home/$USER
ENTRYPOINT ["/bin/bash","-l","-c", "./app"]











