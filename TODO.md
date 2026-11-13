1. [x] Agenix

- [ ] Add the SSH host key of epsilon to `secrets/agenix-rules.nix` and re-encrypt

2. [ ] Switch mounts and ssh back to fixed IPs to survive VPN connections
3. [ ] Rice Waybar

- [ ] Add dnd shortcut (and maybe include into rofi menu)
- [ ] Waybar shortcut for hybernate (maybe also include into rofi menu)
- [ ] Show current virtual desktop number (current + all active on monitor - E.g.: Monitor A -> 1 (2,3) Monitor B -> 0 ()).
- [ ] Drop down for all applications that register at waybay (whatever the name is, maybe applet?)

4. [ ] Keep games active when not focused
5. [ ] Dunstctl window in the middle of the screen, E-Mails and Messages should
       appear longer (maybe with sound even?)
6. [ ] Create a windows like desktop as alternative (and maybe for gaming and
       office stuff)
7. [ ] Impermanence
8. [ ] Move the fonts from the cross-cutting `font.nix` to a shared option
       pulled by each program, like `dotfiles.theme`. See
       `docs/todo/font-shared-option.md`.
9. [ ] Setup a service which tracks the install package versions similar like
       OWASP-DP to get notifications about CVEs
10. [ ] Server metric dashboard like Grafana or include into Glance
11. [ ] 7z and co
12. [ ] SSO service for home network (required for VPN)
13. [ ] Tailscale

- This requires the setup of an additional remote host acting as the proxy
- Security measurements have to be take to prevent access (whitelist). Maybe
  this has to be done in Unifi, but hardening the systems is also necessary
