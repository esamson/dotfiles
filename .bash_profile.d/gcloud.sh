GCLOUD_HOME="$HOME/.local/opt/google-cloud-sdk"

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$GCLOUD_HOME/path.bash.inc" ]; then source "$GCLOUD_HOME/path.bash.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$GCLOUD_HOME/completion.bash.inc" ]; then source "$GCLOUD_HOME/completion.bash.inc"; fi
