#!/usr/bin/env bash
 
cd "$(dirname "${BASH_SOURCE}")"

origin_url=`git remote get-url origin`

dotfiles_dir="$HOME/.dotfiles"

function dotfiles {
    git --git-dir="$dotfiles_dir" --work-tree="$HOME" $@
}

backup_dir="$HOME/.config-backup"
function config_backup {
    cnf_file="$HOME/$1"
    bak_file="$backup_dir/$1"
    mkdir -p "$(dirname $bak_file)"
    mv "$cnf_file" "$bak_file"
}

if [ ! -d "$dotfiles_dir" ]; then
    git clone --bare git@github.com:esamson/dotfiles.git "$dotfiles_dir"

    dotfiles checkout
    if [ $? = 0 ]; then
        echo "Checked out config.";
    else
        export backup_dir
        export -f config_backup

        echo "Backing up pre-existing dot files to $backup_dir."

        dotfiles checkout 2>&1 |
            grep -E "^\s+\S" |
            awk {'print $1'} |
            xargs -I {} bash -c 'config_backup "$@"' _ {}
        dotfiles checkout
        source ~/.bash_profile

        echo "Checked out config. Review changes from $backup_dir";
    fi
    dotfiles config status.showUntrackedFiles no
else
    dotfiles_url=`git --git-dir=$dotfiles_dir remote get-url origin`

    if [ "$origin_url" == "$dotfiles_url" ]; then
        echo "Syncing dotfiles"
        dotfiles checkout
        source ~/.bash_profile
    else
        echo "Can't sync dotfiles. Different sources: $origin_url vs $dotfiles_url"
        exit 1
    fi
fi
