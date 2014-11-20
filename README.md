# BrewCron

Checks every day the outdated packages of Homebrew and sends you a notification.

## How it works

The script creates a launchd task in ~/Library/LaunchAgents that run the script once a day to check the outdates packages.
If you have outdated packages the script sends you a notification.

## Install

Download the script in your favorite location, give it execute permission and run the install command:

    curl -o ~/.brewcron.sh https://raw.githubusercontent.com/inacho/BrewCron/master/brewcron.sh && chmod +x ~/.brewcron.sh && ~/.brewcron.sh install

Note: If you change the location or the name of the script, run again the install command

## Uninstall

Run the uninstall command and remove the script

    ~/.brewcron.sh uninstall && rm ~/.brewcron.sh

## License

Released under the MIT License.
