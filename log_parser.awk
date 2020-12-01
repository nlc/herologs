# heroku logs -t -a <name of service> | awk -f log_parser.awk

# given two nicely-formatted timestamps, return t1 - t2 in seconds
function time_diff(t1, t2) {
  # 2020-03-10T23:36:03.451695+00:00

  if(t1 !~ /[0-9][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\.[0-9][0-9]*\+[0-9][0-9]:[0-9][0-9]/) {
    return 99999999;
  }
  if(t2 !~ /[0-9][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\.[0-9][0-9]*\+[0-9][0-9]:[0-9][0-9]/) {
    return 99999999;
  }

  split(t1, fields1, /[-T:.+]/);
  y1 = fields1[1];
  b1 = fields1[2];
  d1 = fields1[3];
  h1 = fields1[4];
  m1 = fields1[5];
  s1 = fields1[6];

  split(t2, fields2, /[-T:.+]/);
  y2 = fields2[1];
  b2 = fields2[2];
  d2 = fields2[3];
  h2 = fields2[4];
  m2 = fields2[5];
  s2 = fields2[6];

  ds = s1 - s2;
  dm = m1 - m2;
  dh = h1 - h2;
  dd = d1 - d2;
  db = b1 - b2;

  # don't do this at exactly midnight utc at the end of a month, i guess
  return (ds + dm * 60 + dh * 3600 + dd * 86400);
}

# determine if a code should be displayed but not emphasized
function low_priority(code) {
  return code ~ /^H27$/;
}

BEGIN {
  # After this many seconds without a complaint,
  # a given dyno's errors will be reset to 0
  timeout = 60;

  # Describe a field
  # timestamp | "heroku[router]" | key"="field
  FPAT = "[0-9][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\\.[0-9][0-9]*\\+[0-9][0-9]:[0-9][0-9]|heroku\\[router\\]:|\\S+=(\\S+|\"[^\"]+\")";

}

$2 ~ /^heroku\[router\]:$/ {
  timestamp = $1;

  for(key in data) {
    delete data[key];
  }

  for(i = 3; i <= NF; i++) {
    split($i, kvpair, "=");
    key = kvpair[1];
    value = kvpair[2];
    if(key && value) {
      data[key] = value;
    } else {
      print "bad value ", value
      print "or bad key", key
    }
  }

  if(data["code"] ~ /H[0-9][0-9]/) {
    dyno = data["dyno"];
    code = data["code"];

    # if it's been more than <timeout> seconds, reset
    timed_out = 0;
    if(code_counts[dyno "," code] > 0) {
      dt = time_diff(timestamp, last_seen[dyno "," code]);
      if(dt > timeout) {
        timed_out = 1;
        code_counts[dyno "," code] = 0;
      }
    }

    # is it a repeat?
    if(!timed_out && dyno == last_dyno && code == last_code) {
      printf("\033[K\r");
    } else {
      printf("\n");
    }

    code_counts[dyno "," code] += 1;
    code_count = code_counts[dyno "," code];

    # <3 -> normal
    # =2 -> cyan
    # =3 -> yellow
    # >3 -> red
    color_tag = "";
    if(low_priority(code)) {
      if(code_count < 2) {
        color_tag = "\033[2m";
      } else if(code_count > 3) {
        color_tag = "\033[7m";
      }
    } else {
      if(code_count == 2) {
        color_tag = "\033[33m";
      } else if(code_count == 3) {
        color_tag = "\033[31m";
      } else if(code_count > 3) {
        color_tag = "\033[7;31m";
      }
    }


    printf("%s% -10s %s (%s)\033[0m",
           color_tag,
           dyno,
           code,
           code_count);

    if(!low_priority(code)) {
      if(code_count > 3) {
        printf("\033[5;31m *\033[0m");
      }
    }


    last_seen[dyno "," code] = timestamp;
    last_dyno = dyno;
    last_code = code;
  }
}

# TODO: Prevent from spinning too fast
# TODO: Use cursor movement codes to shift the spinner to a safe location
{
  factor = 1;
  frames = "|/-\\";
  printf("\b\b %s", substr(frames, (iframe / factor) + 1, 1));
  iframe = ((iframe + 1) % (length(frames) * factor));
}
