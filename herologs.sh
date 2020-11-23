herologs() {
  local service_name="$DEFAULT_HLOGS_SERVICE"

  if [[ "$#" -gt 0 ]]; then
    service_name="$1"
  fi

  echo
  echo -e "Parsing logs from \033[1m$service_name\033[0m"
  heroku logs -t -a "$service_name" | awk -f log_parser.awk
}

herologs $1
