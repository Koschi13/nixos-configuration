# Only the base generation has the specialisations. Activating a
# specialisation replaces the current generation, so `theme` needs this link
# to find all variants.
#
# Runs inside the Home-Manager activation, which provides `$newGenPath` and
# `run`. `@systemdRun@` and `@theme@` are filled in by `theme-switch.nix`.
themeStateDir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
if [[ -d $newGenPath/specialisation ]]; then
  run mkdir -p "$themeStateDir"
  run ln -sfn "$newGenPath" "$themeStateDir/theme-base"

  # Restores the chosen variant once this activation has finished. A variant
  # that no longer exists falls back to the default.
  if [[ -f $themeStateDir/theme ]]; then
    themeVariant="$(<"$themeStateDir/theme")"
    if [[ -n $themeVariant && -e $newGenPath/specialisation/$themeVariant ]]; then
      run @systemdRun@ --user --no-block --collect \
        --unit=dotfiles-theme-restore --property=After=home-manager.service \
        @theme@ "$themeVariant"
    fi
  fi
fi
