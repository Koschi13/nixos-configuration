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
8. [x] Move the fonts from the cross-cutting `font.nix` to a shared option
       pulled by each program, like `dotfiles.theme`.
9. [x] Setup a service which tracks the install package versions similar like
       OWASP-DP to get notifications about CVEs

- The overview exists (`cve-scan` aspect), the notifications are item 14

10. [ ] Server metric dashboard like Grafana or include into Glance
11. [ ] 7z and co
12. [ ] SSO service for home network (required for VPN)
13. [ ] Tailscale

- This requires the setup of an additional remote host acting as the proxy
- Security measurements have to be take to prevent access (whitelist). Maybe
  this has to be done in Unifi, but hardening the systems is also necessary

14. [ ] Notification channel for the home network

- Self-hosted ntfy (`services.ntfy-sh`) as `ntfy.lan` behind `reverse-proxy`,
  subscribed to by the phone app and the desktops (dunst). Outside the LAN it
  needs item 13 or a relay through the public ntfy.sh.
- A shared `dotfiles.notify` option, like `dotfiles.backup`, so every aspect
  sends through the same channel
- First senders: `cve-scan` (compare the new `summary.json` with the one it
  replaces: a new id + package pair is a new CVE, a changed severity or fix is
  an update), failed backups and failed systemd units
