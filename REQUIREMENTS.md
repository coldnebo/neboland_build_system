# Requirements

* ConEmu: https://conemu.github.io/
* Ruby for windows: https://rubyinstaller.org/
* git for windows: https://git-scm.com/download/win

## Environment

* Windows 10
* Steam
* Arma3

# Setup

run a git-bash shell inside of conemu and find a place
where you want to pull your server project.

Run:

        $ git clone thisproject
        $ cd thisproject
        $ gem install bundle
        $ bundle install

Configure:

        $ cp sample_config.json myserver.json

Modify your configuration to taste.

Build: 

        $ rake build

Test (Runs a server locally for testing):

        $ rake test

Deploy:

        $ rake deploy


