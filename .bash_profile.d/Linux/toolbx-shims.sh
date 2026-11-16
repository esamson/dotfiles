# Use shims when running from within toolbx
if [[ -f /run/.toolboxenv ]]; then
  pathmunge /home/edu/.local/bin/shims
fi
