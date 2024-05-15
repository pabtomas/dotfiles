#! /bin/sh

volume "${COMPOSE_PROJECT_NAME}"
volume "${SPACEPORN_ID}"
volume "${SAFEDEPOSIT_ID}"
delme_volume 'proxy_ngx_fs' "${PROXY_ID}-etc-nginx-fs"
delme_volume 'proxy_scripts_fs' "${PROXY_ID}-opt-scripts-fs"
delme_volume 'collector_var_log' "${COLLECTOR_ID}-var-log-fs"
delme_volume 'collector_etc_crontabs' "${COLLECTOR_ID}-etc-crontabs-fs"
delme_volume 'collector_opt_data' "${COLLECTOR_ID}-opt-data-fs"
delme_volume 'collector_opt_scripts' "${COLLECTOR_ID}-opt-scripts-fs"
delme_volume 'ssh' 'shared-ssh'
