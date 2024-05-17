#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

sfx "${COMPONENT_ID}${ID_SFX}"
sfx "${EXPLORER_ID}${ID_SFX}"
sfx "${COMPONENT_ID}${IMG_SFX}"
sfx "${LOCAL_ID}${IMG_SFX}"
sfx "${EXPLORER_ID}${HOST_SFX}"
sfx "${EXPLORER_ID}${SERVICE_SFX}"
sfx "${COMPONENT_ID}${TAG_SFX}"
