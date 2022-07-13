herologs() {
  local service_name=

  if [[ "$#" -gt 0 ]]; then
    service_name="$1"
  elif $(type select_kicksite_app &>/dev/null); then
    service_name="$(select_kicksite_app)"
  elif [[ -n "$DEFAULT_HLOGS_SERVICE" ]]; then
    service_name="$DEFAULT_HLOGS_SERVICE"
  else
    echo -e "\033[31mError:\033[0m \"select_kicksite_app\" is not available and the"
    echo -e "       default name \$DEFAULT_HLOGS_SERVICE is not set!"
    echo -e "       Please provide a service name argument."
  fi

  if [[ -z "$service_name" ]]; then
    echo -e "No service name provided, aborting."
    return
  fi

  heroku logs -t -a "$service_name"
}

herologs_errors() {
  echo
  echo -e "Parsing logs from \033[1m$service_name\033[0m"

  herologs "$1" | gawk -f log_parser.awk
}

herologs_test() {
  gawk -f 'log_parser.awk' 'test.txt'
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

# herologs $1
