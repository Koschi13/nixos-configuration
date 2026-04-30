# systems

This defines common settings for all systems. The hierachy is:

1. default (baseline)
2. server (CLI configuration base for servers and desktops alike)
3. desktop (graphical configuration for desktops only)

They inherit from each other in that order, so a `server` always has `default`
inherited and a `desktop` contains `server` + `default`.

TODO: maybe server should be on the same level as desktop and a CLI is the shared stuff?
