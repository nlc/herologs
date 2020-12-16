# herologs
Parse Heroku service logs to monitor errors using only ~~vanilla AWK~~ GNU AWK.

TODO: Current syntax tricks require gawk. Investigate refactoring so that only awk is needed.

<img width=300px src="https://github.com/nlc/herologs/raw/master/screenshot.png?raw=true">

Provides a simple at-a-glance overview of the service state. Useful for instantly pinpointing a misbehaving dyno.
