ARG ZIG_IMG
ARG OS

FROM ${ZIG_IMG} as zig_img
FROM ${OS}

COPY --from=zig_img /usr/local/bin/zig /usr/local/bin
COPY --from=zig_img /usr/local/bin/lib /usr/local/bin

# Remove this later
ENTRYPOINT ["tail", "-f", "/dev/null"]
