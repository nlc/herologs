herologs() {
  local service_name="$DEFAULT_HLOGS_SERVICE"


  if [[ "$#" -gt 0 ]]; then
    service_name="$1"
  elif [[ -z "$service_name" ]]; then
    echo -e "\033[31mError:\033[0m Default name \$DEFAULT_HLOGS_SERVICE not set!"
    echo -e "       Use \033[1mexport DEFAULT_HLOGS_SERVICE=<service name>\033[0m"
    echo -e "       or provide a service name argument."
    return
  fi

  echo
  echo -e "Parsing logs from \033[1m$service_name\033[0m"
  heroku logs -t -a "$service_name" | gawk -f log_parser.awk
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
