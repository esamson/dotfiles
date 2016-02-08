sudo dnf install -y tmux

# Workaround for tmux window titles. See: https://bugzilla.redhat.com/show_bug.cgi?id=969429#c27
sudo ln -s /usr/bin/true /etc/sysconfig/bash-prompt-screen
