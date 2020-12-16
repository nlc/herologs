herologs() {
  local service_name="$DEFAULT_HLOGS_SERVICE"

  if [[ "$#" -gt 0 ]]; then
    service_name="$1"
  fi

  echo
  echo -e "Parsing logs from \033[1m$service_name\033[0m"
  heroku logs -t -a "$service_name" | awk -f log_parser.awk
}

herorestart() {
  if [[ "$#" -eq 0 ]]; then
    echo "Usage: herorestart <dyno_name>"
    return
  fi

  for dyno_name in $@; do
    heroku dyno:restart "$dyno_name" -a kicksite-prod
  done
}

herologs $1
