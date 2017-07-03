# NeboLand Build System

This project is the beginning of a clean build of the 
NeboLand Exile server with an emphasis on total build 
automation and best practices.


## Background

The ARMA dev community has slowly started using github,
but there is still a wide collection of code and practice that 
is stored in dated blog posts, zip files and snippets... it makes 
it very difficult to provide a consistent build or even proper updates.

Updaters are varied, however Steam seems to be gaining prominence for
many of the open source mods.  For other mods, we need a 
way to systematically pull updates and deploy changes, while keeping
changes to the system under source control.  Commercial tools (like infiSTAR) 
should also be excluded from source control.

We also need to distinguish between build artifacts, security credentials
and source. The current ad-hoc processes lead many people to avoid 
sharing any server code for fear of exposing credentials to everyone.

Because of this, it's very difficult to share or even see the arcane art
of setting up Arma with various server hosts.


## Purpose

The purpose of this project is to systematize the build process so that
a one-step build and deployment is possible.  This will make it easier to 
track changes to subprojects and auto-generate build outputs.

Additionally, I want to separate credentials from the scripts so that the core
of this build system can be shared on github and used by other people who want to 
extend and modify it without going through the considerable learning curve and 
time investment to setup a proper build chain.

I hope this will expand the reach and fun for Arma servers, it's really an 
awesome game with a huge amount of potential for the custom mod/dev community.


## Instructions

Please find complete instructions in the [BUILD.md](./BUILD.md) file.

