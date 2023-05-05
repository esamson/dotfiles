podman_socket="/run/user/$UID/podman/podman.sock"
if [ -S "$podman_socket" ]; then
    export DOCKER_HOST="unix://$podman_socket"

    # https://www.testcontainers.org/features/configuration/#disabling-ryuk
    export TESTCONTAINERS_RYUK_DISABLED=true
fi
unset podman_socket
