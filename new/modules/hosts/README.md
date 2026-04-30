# hosts

Contains the individual configurations per host.

This is basically the main entrypoint for the flake on each system, which
defines what packages and configurations each host has as well as the users
which are active on that host.
The users itself then have individual configurations you can find in
`modules/users`.
