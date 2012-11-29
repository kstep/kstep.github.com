---
title: "Dbuscron"
layout: default 
---
**Upd:** I've just release version 1.3. You can download [deb-package for Maemo 5](../../../download/71). The build includes one new feature and some improvements in log messages and error handling:

  - new cli args: userid and groupid to set user and group to change too
  - moved user & group id setting code into separate function
  - main module code cleanup: more comments & logging, better error handling etc.
  - Makefile: debclean & deb targets
  - auto version setting
  - Makefile: build target
  - changelog updated

The main feature of the build is two new options `--userid` and `--groupid`. They make daemon change its process's user and group id. You may need it for two reasons: for security, and to run the daemon on other user's sessions bus. These options work only if dbuscron is run by the root itself, of cause. You can pass either numeric id of user/group or their name as value for these options. If you pass `--userid` only, the process's group will be set to main group of given user.

* * *

**Upd:** The new 1.2 version is out. You can download [deb-package for Maemo 5](../../../download/70). It includes some fixes and code improvements:

  - dbuscron uses optparse instead of getopt
  - Makefile: ignore error on existing config
  - more robust and unicode safe dbus string handling
  - fixed unset session bus address issue
  - more robust loggin of unicode messages
  - better log messages
  - dbuscrontab: refactored error handling
  - moved shell part into modules
  - Makefile updated
  - changelog updated

Besides that I've forgotten to mention dbuscrontab utility used to edit dbuscron's config flawlessly. It works just like crontab utility from good old cron daemon. It accepts one of following arguments:

  - _-l_ — show config to standard output,
  - _-k_ — check config for syntax errors,
  - _-e_ — edit config with standard system editor (set in `EDITOR` environment variable or `/usr/bin/vim` if this variable is not set).

The most useful argument is _-e_. Use `dbuscrontab -e` to edit system-wide config. The reasons a many:

  1. it edits copy of /etc/dbuscrontab, not this file itself, so you are protected from system crashes like power or software failures,
  2. it replaces original config with updated copy only if editor is finished correctly and the copy is really changed,
  3. and the last, but the most important thing: it checks copy you changed for syntax errors before overwriting system-wide config, so even you make some mistake your main config will stay safe and intact.

And here are dbuscron's arguments:

  - _-f, --nodaemon_ — run daemon in foreground, e.g. for testing;
  - _-l, --log, --logfile_ — set log file to put standard error and output, used for both run programs and dbuscron itself output messages, doesn't work with _-f_;
  - _-c, --conf, --config_ — set config file instead of default `/etc/dbuscrontab`;
  - _-q, --quiet_ — make daemon more quiet, can be repeated several times to hide more critical errors from log output;
  - _-v, --verbose_ — make daemon more verbose, can be repeated several times to show more debug and information messages (less important messages);

* * *

After several cleanups I decided to present my cron-like DBUS messages scheduler to community. I made it for my N900, so deb-package is created for Maemo 5, but the daemon itself can be used on any Linux-based OS with DBUS. Written in Python.

It work pretty simply: just run dbuscron and be happy =)

But you better config it before running to make it useful. Main dbuscron's config file is /etc/dbuscrontab and looks like crontab files. Every line is a rule to match DBUS messages. These rules consist of nine parts: bus (either “S” for system bus or “s” for session bus), message type (signal, method_call, method_return or error), source name, interface name, object path, member method name, destination name, message arguments and command to run on matched message.

Every field can have many values to match separated with comma, or can have single star (*) to match any value. Arguments field can have several argument values separated with semi-colon, rule will match message only if all rule argument values match DBUS message argument values.

You can also set environment variables in any place of config as “NAME=VALUE” pairs, one variable per line.

Besides that these environment variables are set by dbuscron for commands run on matched message:

  - DBUS_ARG# (where # is a number between 0 and DBUS_ARGN-1) – message arguments,
  - DBUS_ARGN – number of message arguments,
  - DBUS_SENDER – sender's name,
  - DBUS_DEST – destination name,
  - DBUS_IFACE – message interface,
  - DBUS_PATH – object path,
  - DBUS_MEMBER – member method,
  - DBUS_BUS – bus name, either “session” or “system”,
  - DBUS_TYPE – message type (signal, method_call, method_return or error).

Empty lines and lines starting with “#” are ignored as always =)

I can tell you about abilities of the daemon for many hours, but example of my own config is more useful in this case:
    
    # Stop player on headphones plug out  
    S signal * org.freedesktop.Hal.Device /org/freedesktop/Hal/devices/platform_headphone Condition * ButtonPressed;connection grep -q disconnected /sys/devices/platform/gpio-switch/headphone/state && run-standalone.sh /opt/userscripts/mpcontrol.sh stop
    # Say incoming number with espeak  
    S signal * com.nokia.csd.Call /com/nokia/csd/call Coming * * run-standalone.sh /opt/userscripts/tasks/speak-caller.sh  
    # Connect to ISP via PPTP on home WiFi network connection  
    S signal * com.nokia.wlancond.signal /com/nokia/wlancond/signal connected * wlan0 run-standalone.sh /opt/userscripts/tasks/connect-pptp.sh  
    # Disconnect PPTP  
    S signal * com.nokia.wlancond.signal /com/nokia/wlancond/signal disconnected * wlan0 run-standalone.sh /opt/userscripts/tasks/disconnect-pptp.sh  
    # Switch to 3G mode on GPRS connected to make it faster  
    S signal * com.nokia.csd.GPRS.Context /com/nokia/csd/gprs/0 Connected * * /opt/userscripts/radiomode.sh both  
    # Switch back to GSM mode only on GPRS disconnected to save battery  
    S signal * com.nokia.csd.GPRS.Context /com/nokia/csd/gprs/0 Disconnected * * /opt/userscripts/radiomode.sh gsm  
    # This message comes on cell changed:  
    #S signal * Phone.Net /com/nokia/phone/net cell_info_change * status;lac;cid;mnc;mcc;services;userdata command  
    # This message comes on operator name changed:  
    #S signal * Phone.Net /com/nokia/phone/net operator_name_change * status;opname;unk;mnc;mcc command  
    # Show notification message on operator name changed:  
    S signal * Phone.Net /com/nokia/phone/net operator_name_change * * run-standalone.sh /opt/userscripts/tasks/show-opname.sh

That's it, there're really many possibilities as you can see =)

This daemon can be found on my github account here: [http://github.com/kstep/dbuscron](http://github.com/kstep/dbuscron). Or you can download deb-package for Maemo 5 from [here](../../../download/69).
