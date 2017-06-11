# NeboLand 

NeboLand Arma3/Exile/Zombies/Raptors is an exciting place.  Soon we will be opening up for public fun.


## Server Assumptions

While I have made an attempt to generalize these build scripts for multiple situations, I 
am developing for my specific situation with the following assumptions:

* Windows 10
* [Ruby for Windows](https://rubyinstaller.org/)
* [git for Windows](https://git-scm.com/downloads)
* [Host Havoc](https://hosthavoc.com/) - there are many game servers, 
  as well as rolling your own, this just happens to be the one we use.
* [Steam](http://store.steampowered.com/) - Arma 3 and Arma 3 Tools should be installed.
* I let Host Havoc own the Exile mod since there is database integration that they script and support.
* I let Steam Workshop download and update most of the other mods that I use.

Most of this project should build out of the box, but you may have to comment out steps for 
infiSTAR if you don't purchase that, and possibly change the maps data.


## Structure

        .
        config.json              # make your own from the config-example.json included in the project.
        config-example.json      # example to show where to place your private credentials, etc.



## Rake tasks

        $ rake -T
        rake build        # build the server
        rake clean        # Remove any temporary products
        rake clobber      # Remove any generated files
        rake deploy       # deploy the server
        rake generate     # generate command line for mods
        rake update_mods  # update steam managed mods to server




### update_mods

This task is designed to make it easier to sync your steam workshop mods to your host via ftp.

Steps:

* ftp to your host and delete the mod folder you want to update (e.g. @CBA_A3/)
* run 'rake update_mods'.  The task will check if the target mod folder exists and if it doesn't it will 
  ftp copy the mod from your Steam Workshop folder to your server.

NOTE: I went this way because HostHavoc doesn't provide access to the steamcmd directly (mostly for credential and
security reasons), otherwise I could have subscribed to various mods and used the steamcmd to automatically update 
these mods in place (which can be faster/more efficient than ftpping fresh copies up and deleting unneed files from the updates).

If you run your own linux server, I would recommend checking out Linux Game Server Managers (gsm) which 
has a really nice [arma3server](https://gameservermanagers.com/lgsm/arma3server/) base you can build from.


## Default Arma3 Server

* hosthavoc Arma3
* from a fresh start/reinstall
  remember to set the RCON pw to what you want via the gui.

* default commandline:

          -ip=<ip> -port=<port> -noPause -noSound "-cfg=A3DS\basic.cfg" "-config=A3DS\server.cfg" "-profiles=A3DS" -world=empty

* /A3DS/Server.cfg
You will need to update the Missions section from Changeme.Altis to one of the actual MP missions.

## Submodule management

$ git submodule update

can cd into submod: e.g. source/mods/DMS_Exile and do regular git ops from there.

