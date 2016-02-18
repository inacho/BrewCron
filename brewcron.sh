#!/usr/bin/env bash

# BrewCron: Checks every day the outdated packages of Homebrew and sends you a notification
#
# The MIT License
#
# Copyright (c) 2014 Ignacio de Tomás, http://inacho.es
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


if [[ $1 == "install" ]]; then

    # PATHS

    agents="$HOME/Library/LaunchAgents"
    plist="$agents/es.inacho.brewcron.plist"
    script="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/$( basename "${BASH_SOURCE[0]}" )"

    mkdir -p "$agents"

    # DELETE PREVIOUS VERSION

    if [[ -f "$plist" ]]; then
        launchctl unload "$plist"
        rm -f "$plist"
    fi

    # CREATE PLIST

    read -d '' plistcontent <<- EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>es.inacho.brewcron</string>
    <key>ProcessType</key>
    <string>Background</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>TERM</key>
        <string>ansi</string>
    </dict>
    <key>ProgramArguments</key>
    <array>
        <string>$script</string>
        <string>check</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>0</integer>
        <key>Minute</key>
        <integer>5</integer>
    </dict>
</dict>
</plist>
EOF

    echo "$plistcontent" > "$plist"

    # CREATE TASK

    launchctl load "$plist"

    echo "Loaded brewcron"


elif [[ $1 == "uninstall" ]]; then

    # PATHS

    agents="$HOME/Library/LaunchAgents"
    plist="$agents/es.inacho.brewcron.plist"

    # DELETE TASK

    launchctl unload "$plist"
    rm -f "$plist"

    echo "Unloaded brewcron"

elif [[ $1 == "check" ]]; then

    # NOTIFICATION PARAMS

    title="Homebrew"
    subtitle="Updates available"
    sound="default"

    # UPDATE HOMEBREW

    /usr/local/bin/brew update > /dev/null
    outdated=$(/usr/local/bin/brew outdated)

    # SEND NOTIFICATION

    if [[ ! -z $outdated ]]; then
        if [[ -f /Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier ]]; then
            /Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "$title" -subtitle "$subtitle" -message "$outdated" -sound "$sound"
        else
            /usr/bin/osascript -e "display notification \"$outdated\" with title \"$title\" subtitle \"$subtitle\" sound name \"$sound\""
        fi
    fi

else

    echo "usage: $0 install|uninstall|check"

fi
