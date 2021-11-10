. /etc/profile.d/app-env.sh
[[ "$SUDO_USER" != "$APP_USER" ]] && su $APP_USER
