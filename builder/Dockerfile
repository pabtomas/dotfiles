ARG _BUILDKIT_LOCAL_IMG
FROM ${_BUILDKIT_LOCAL_IMG}

ARG BUILDER_PORT
CMD ["--addr", "tcp://0.0.0.0:${BUILDER_PORT}", "--oci-worker-no-process-sandbox"]

EXPOSE ${BUILDER_PORT}
