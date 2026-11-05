{self, ...}: {
  flake.modules.homeManager.glance = {osConfig, ...}: {
    imports = [self.modules.homeManager.stylix];

    stylix.targets.glance.enable = true;

    # Provides GLANCE_LOCATION, decrypted by agenix (see `nixos.max`)
    systemd.user.services.glance.Service.EnvironmentFile = osConfig.age.secrets.glance-env.path;

    services.glance = {
      enable = true;
      settings = {
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
          port = 5678;
        };
      };
    };
  };
}
