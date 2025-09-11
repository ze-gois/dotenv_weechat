#!/usr/bin/zsh

set -e

. ../setup/environment.zsh
. ../setup/library.zsh

# Caminho do script atual
current() {
    local script="${(%):-%x}"
    origin "$script"
}

SETUP_PATH=$(dirname "$(current)")

echo "[+] Configuring WeeChat module..."

# Prompt para todas as senhas/configurações
prompt_pass "weechat/passphrase" "Weechat Passphrase" "${WEECHAT_PASSPHRASE}"
prompt_pass "weechat/relay_pass" "Weechat Relay Pass" "${WEECHAT_RELAY_PASS}"
prompt_pass "weechat/libera_pass" "Weechat Libera Pass" "${WEECHAT_LIBERA_PASS}"
prompt_pass "weechat/default_nicks" "Weechat Default Nicks" "${WEECHAT_DEFAULT_NICKS}"
prompt_pass "weechat/default_sasl_user" "Weechat Default SASL User" "${WEECHAT_DEFAULT_SASL_USER}"
prompt_pass "weechat/log_path" "Weechat Log Path" "${WEECHAT_DEFAULT_LOG_PATH}"

# Mata sessão anterior se existir
tmux kill-session -t weechat 2>/dev/null || true

# Comandos do WeeChat (string única com separador ;)
WEECMD=$(
  cat <<EOF | tr '\n' ';'
/plugin list
/plugin load logger
/logger reload
/logger disable *
/logger enable *
/set logger.file.auto_log on
/set logger.level.irc 3
/set logger.file.name "%Y-%m-%d_%n.weechatlog"
/set logger.file.path ${WEECHAT_DEFAULT_LOG_PATH}/%h/%Y-%m
/secure passphrase $(pass show weechat/passphrase)
/secure set relay_pass ${WEECHAT_RELAY_PASS}
/secure set libera_pass ${WEECHAT_LIBERA_PASS}
/secure set default_nicks ${WEECHAT_DEFAULT_NICKS}
/secure set default_sasl_user ${WEECHAT_DEFAULT_SASL_USER}
/exec -o -sh -oc cat ${SETUP_PATH}/setup/**/*
EOF
)

# Inicia sessão tmux com o WeeChat usando o bloco
tmux new-session -s weechat "weechat --stdout -r '$WEECMD'"

echo "[+] WeeChat setup complete!"
echo "Use: tmux attach -t weechat"
