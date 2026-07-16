{rootPath, ...}: let
  private = import "${rootPath}/.secrets/private.nix";
in {
  services.glance = {
    enable = true;
    settings = {
      theme = {
        # Unfortunately you have to specify the default + default-dark/light
        light = false;
        background-color = "229 19 23";
        primary-color = "222 74 74";
        positive-color = "96 44 68";
        negative-color = "359 68 71";

        disable-picker = false;

        presets = {
          default-dark = {
            # catppuccin-frappe
            light = false;
            background-color = "229 19 23";
            primary-color = "222 74 74";
            positive-color = "96 44 68";
            negative-color = "359 68 71";
          };

          default-light = {
            # catppuccin-latte
            light = true;
            background-color = "220 23 95";
            contrast-multiplier = 1.0;
            primary-color = "220 91 54";
            positive-color = "109 58 40";
            negative-color = "347 87 44";
          };
        };
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
                  location = "${private.location.name}, ${private.location.country}";
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
}
