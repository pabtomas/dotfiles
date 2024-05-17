ARG ZIG_IMG
ARG OS_LOCAL_IMG

FROM ${ZIG_IMG} as zig_img
FROM ${OS_LOCAL_IMG}

COPY --from=zig_img /usr/local/bin/zig /usr/local/bin
COPY --from=zig_img /usr/local/bin/lib /usr/local/bin
