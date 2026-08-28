# When running podman from within toolbx
if [[ -f /run/.toolboxenv ]]; then
  podman() {
    flatpak-spawn --host podman "$@"
  }
fi
