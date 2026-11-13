{
  inputs,
  self,
  ...
}: {
  # The Glance dashboard on http://glance.lan, behind `reverse-proxy`. Runs as
  # a system service with a dynamic user, which can't read /home, so it can't
  # reach the files or the forwarded gpg-agent sockets of the users.
  #
  # Needs the `glance-env` secret of `secrets/README.md`.
  flake.modules.nixos.glance = {
    config,
    lib,
    pkgs,
    ...
  }: let
    domain = "glance.lan";
    inherit (config.services.glance.settings.server) host port;

    # The default variant of the theme, in the colours the stylix target of
    # Home-Manager would set. stylix only themes Glance in Home-Manager.
    theme =
      (lib.evalModules {
        class = "homeManager";
        modules = [self.modules.homeManager.dotfiles-theme];
      }).config.dotfiles.theme.active;
    colors = (inputs.stylix.inputs.base16.lib {inherit pkgs lib;}).mkSchemeAttrs theme.scheme;
    hsl = import "${inputs.stylix}/modules/glance/rgb-to-hsl.nix" {inherit lib colors;};
  in {
    imports = [self.modules.nixos.reverse-proxy];

    # Provides GLANCE_LOCATION. Read by systemd before it drops privileges, so
    # root may own it.
    age.secrets.glance-env.file = "${self}/secrets/glance-env.age";

    services.nginx.virtualHosts.${domain}.locations."/".proxyPass = "http://${host}:${toString port}";

    services.glance = {
      enable = true;
      environmentFile = config.age.secrets.glance-env.path;
      settings = {
        theme = {
          light = theme.polarity == "light";
          contrast-multiplier = 1.0;
          background-color = hsl "base00";
          primary-color = hsl "base05";
          positive-color = hsl "base0B";
          negative-color = hsl "base08";
        };
        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "clock";
                    hour-format = "24h";
                    timezones = [
                      {
                        timezone = "Europe/Berlin";
                        label = "Berlin";
                      }
                    ];
                  }
                  {
                    type = "calendar";
                    first-day-of-week = "monday";
                  }
                  {
                    type = "weather";
                    hour-format = "24h";
                    # Substituted by glance at runtime
                    location = "\${GLANCE_LOCATION}";
                    units = "metric";
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  {
                    type = "rss";
                    title = "Blogs";
                    style = "detailed-list";
                    collapse-after = 10;
                    feeds = [
                      {
                        url = "https://andrewkelley.me/rss.xml";
                        title = "Andrew Kelly (Zig)";
                      }
                      {
                        url = "https://kristoff.it/index.xml";
                        title = "Loris Cro (Zig)";
                      }
                      {
                        url = "https://bryananthonio.com/rss.xml";
                        title = "Bryan Anthonio (Homelab)";
                      }
                      {
                        url = "https://mitchellh.com/feed.xml";
                        title = "Mitchell Hashimoto (Zig, Go, HashiCorp)";
                      }
                      {
                        url = "https://stephango.com/feed.xml";
                        title = "Steph Ango (Obsidian)";
                      }
                      {
                        url = "https://martinfowler.com/feed.atom";
                        title = "Martin Fowler (SoftwareArchitecture)";
                      }
                      {
                        url = "https://burntsushi.net/index.xml";
                        title = "Andrew Gallant (Rust)";
                      }
                      {
                        url = "https://lucumr.pocoo.org/feed.xml";
                        title = "Armin Ronacher (Python)";
                      }
                      {
                        url = "https://aibodh.com/feed.xml";
                        title = "Febin John James (Rust, GameDev)";
                      }
                      {
                        url = "https://piechowski.io/index.xml";
                        title = "Ally Piechowski (SoftwareEngineering)";
                      }
                      {
                        url = "https://dannorth.net/blog/index.xml";
                        title = "Daniel Terhorst-North (SoftwareArchitecture)";
                      }
                      {
                        url = "https://bartoszmilewski.com/feed/";
                        title = "Bartosz Milewski (FunctionalProgramming)";
                      }
                      {
                        url = "https://samizdat.dev/index.xml";
                        title = "Egor Kovetskiy (SoftwareEngineering, Go)";
                      }
                      {
                        url = "https://tyrrrz.me/blog.rss";
                        title = "Oleksii Holub (SoftwareEngineering, C#)";
                      }
                      {
                        url = "https://felixrieseberg.com/rss";
                        title = "Felix Rieseberg (Electron, Anthropic, Slack, Microsoft)";
                      }
                    ];
                  }
                ];
              }
            ];
          }
          {
            name = "News";
            columns = [
              {
                size = "full";
                widgets = [
                  {
                    type = "hacker-news";
                  }
                  {
                    type = "lobsters";
                  }
                ];
              }
            ];
          }
        ];
        server = {
          host = "127.0.0.1";
          port = 5678;
        };
      };
    };
  };
}
