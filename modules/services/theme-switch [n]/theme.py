# Switches between the variants of `dotfiles.theme` at runtime.
#
# All variants are built by every rebuild, each one but the default as
# Home-Manager specialisation. Switching runs the already built activation,
# so no rebuild is needed. The variants are read from the base generation, so
# this script doesn't know any of them by name.

import argparse
import os
import shutil
import signal
import subprocess
import sys
from pathlib import Path

STATE_HOME = os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")
STATE_DIRECTORY = Path(STATE_HOME) / "dotfiles"
STATE_FILE = STATE_DIRECTORY / "theme"
# Maintained by the activation of the base generation, see `theme-switch.nix`
BASE = STATE_DIRECTORY / "theme-base"

RUNTIME_DIRECTORY = Path(
    os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
)
NVIM_APPLY = 'luaeval("require(\\"dotfiles_theme\\").apply()")'


def default_variant():
    # Every generation names its variant, see `theme-switch.nix`
    return (BASE / "theme-variant").read_text().strip()


def variants():
    """The default variant first, then the specialisations by name."""
    specialisations = sorted(
        path.name for path in (BASE / "specialisation").iterdir()
    )
    return [default_variant(), *specialisations]


def current_variant():
    if STATE_FILE.is_file():
        variant = STATE_FILE.read_text().strip()
        if variant in variants():
            return variant
    return default_variant()


def next_variant():
    available = variants()
    position = available.index(current_variant())
    return available[(position + 1) % len(available)]


def activate(variant):
    STATE_DIRECTORY.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(f"{variant}\n")

    if variant == default_variant():
        generation = BASE
    else:
        generation = BASE / "specialisation" / variant
    # Same driver version as the activation of the NixOS module: the
    # Home-Manager Nix profile is left alone.
    # Version 1 means that Home-Manager is managed by NixOS and not
    # standalone.
    subprocess.run(
        [generation / "activate", "--driver-version", "1"], check=True
    )


def run_quietly(*command):
    subprocess.run(
        command,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )


def signal_processes(name, signal_number):
    # Nix wraps some programs, their executable is then `.<name>-wrapped`.
    # `comm` doesn't help, it's cut to 15 characters.
    executables = {name, f".{name}-wrapped"}
    for process in Path("/proc").iterdir():
        try:
            if Path(os.readlink(process / "exe")).name in executables:
                os.kill(int(process.name), signal_number)
        except (OSError, ValueError):
            # Not a process, or it exited in the meantime
            continue


def reload_programs():
    # Programs that don't pick up their changed configuration on their own.
    # Alacritty, rofi and starship read it themselves, dunst is restarted by
    # the activation.
    if "SWAYSOCK" in os.environ and shutil.which("swaymsg"):
        # Respawns waybar as well
        run_quietly("swaymsg", "reload")

    signal_processes("ghostty", signal.SIGUSR2)

    if shutil.which("dunstctl"):
        run_quietly("dunstctl", "reload")

    if shutil.which("nvim"):
        for socket in RUNTIME_DIRECTORY.glob("nvim.*"):
            if socket.is_socket():
                run_quietly(
                    "nvim", "--server", socket, "--remote-expr", NVIM_APPLY
                )


def main():
    if not (BASE / "specialisation").is_dir():
        sys.exit(f"theme: {BASE} is missing, apply the configuration once")

    parser = argparse.ArgumentParser(
        prog="theme", description="Switches the theme variant."
    )
    parser.add_argument(
        "command", choices=[*variants(), "toggle", "status", "list"]
    )
    command = parser.parse_args().command

    if command == "status":
        print(current_variant())
    elif command == "list":
        print("\n".join(variants()))
    else:
        activate(next_variant() if command == "toggle" else command)
        reload_programs()


main()
