#!/usr/bin/env sh

. ./env.sh
. ./lib.sh

echo "[+] Configuring WeeChat module..."

prompt_pass "weechat/passphrase" "Weechat Passphrase" "${WEECHAT_PASSPHRASE}"
prompt_pass "weechat/relay_pass" "Weechat Relay Pass" "${WEECHAT_RELAY_PASS}"
prompt_pass "weechat/libera_pass" "Weechat Libera Pass" "${WEECHAT_LIBERA_PASS}"
prompt_pass "weechat/default_nicks" "Weechat Default Nicks" "${WEECHAT_DEFAULT_NICKS}"
prompt_pass "weechat/default_sasl_user" "Weechat Default SASL User" "${WEECHAT_DEFAULT_SASL_USER}"
prompt_pass "weechat/log_path" "Weechat Log Path" "${WEECHAT_DEFAULT_LOG_PATH}/%h/%Y-%m"

weechat -c "
/plugin list
/plugin load logger
/logger reload
/logger disable *
/logger enable *
/set logger.file.auto_log on
/set logger.level.irc 3
/set logger.file.path ${WEECHAT_DEFAULT_LOG_PATH}/%h/%Y-%m
/secure passphrase ${WEECHAT_PASSPHRASE}
/secure set relay_pass ${WEECHAT_RELAY_PASS}
/secure set libera_pass ${WEECHAT_LIBERA_PASS}
/secure set default_nicks ${WEECHAT_DEFAULT_NICKS}
/secure set default_sasl_user ${WEECHAT_DEFAULT_SASL_USER}
/exec -sh -oc cat ./setup/03-weechat_script
"

echo "[+] WeeChat setup complete!"
