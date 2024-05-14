ARG ZIG_COMPONENT_IMG
ARG GIT_COMPONENT_IMG

FROM ${ZIG_COMPONENT_IMG} as zig_image
FROM ${GIT_COMPONENT_IMG}

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    unset http_proxy https_proxy
END_OF_RUN

COPY --from=zig_image /usr/local/bin/ /usr/local/bin/
