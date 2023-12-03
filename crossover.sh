#!/usr/bin/env bash

# checck if pidof exists
PIDOF="$(which pidof)"
# and if not - install it
(test "${PIDOF}" && test -f "${PIDOF}") || brew install pidof

# find app in default paths
CO_PWD=~/Applications/CrossOver.app/Contents/MacOS
test -d "${CO_PWD}" || CO_PWD=/Applications/CrossOver.app/Contents/MacOS

test -d "${CO_PWD}" || (echo 'unable to detect app path. exiting...' && exit)

PWD="${CO_PWD}"
cd "${PWD}"

PROC_NAME='CrossOver'

# get all pids of CrossOver
pids=(`pgrep "${PROC_NAME}"`, `pidof "${PROC_NAME}"`, `ps -Ac | grep -m1 "${PROC_NAME}" | awk '{print $1}'`)
pids=`echo ${pids[*]}|tr ',' ' '`

# kills CrossOver process if it is running
[ "${pids}" ] && kill -9 `echo "${pids}"` > /dev/null 2>&1

# wait until app finish
sleep 3

# make the current date RFC3339-encoded string representation in UTC time zone
DATETIME=`date -u -v -3H  '+%Y-%m-%dT%TZ'`

# modify time in order to reset trial
plutil -replace FirstRunDate -date "${DATETIME}" ~/Library/Preferences/com.codeweavers.CrossOver.plist
plutil -replace SULastCheckTime -date "${DATETIME}" ~/Library/Preferences/com.codeweavers.CrossOver.plist

# show tooltip notification 
/usr/bin/osascript -e "display notification \"trial fixed: date changed to ${DATETIME}\""

# reset all bottles
for file in ~/Library/Application\ Support/CrossOver/Bottles/*/.{eval,update-timestamp}; do rm -rf "${file}";done

for file in ~/library/Application\ Support/Crossover/Bottles/*/system.reg;do perl -pi -e 'BEGIN {undef $/;} s/\[Software\\\\CodeWeavers\\\\CrossOver\\\\cxoffice\].*\n.*\n.*\n.*\n.*\n\n//g' $file; done

# and after this execute original crossover
echo "${PWD}" > /tmp/co_log.log
"$($PWD/CrossOver.origin)" >> /tmp/co_log.log
