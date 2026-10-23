#!/usr/bin/env bash
set -euo pipefail

repo_url=https://github.com/LunaDash-DE/LunaDash-Shell.git
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
prefix=${HOME:?HOME must be set}/.local
custom_data_home=${XDG_DATA_HOME:-}
prefix_set=false
destdir=
dry_run=false

usage() {
    cat <<'EOF'
Usage: ./install.sh [--prefix DIR] [--destdir DIR] [--dry-run]

Install this LunaDash Shell revision to PREFIX/share/lunadash/shell.
By default, files go to ~/.local/share/lunadash/shell, or to
XDG_DATA_HOME/lunadash/shell when XDG_DATA_HOME is set.
For a system install, use: sudo ./install.sh --prefix /usr

When run from a downloaded installer without the source tree, the script
fetches the current main branch first. It requires git and Bash.
EOF
}

while (($#)); do
    case "$1" in
        --prefix) (($# >= 2)) || { usage >&2; exit 2; }; prefix=$2; prefix_set=true; shift ;;
        --destdir) (($# >= 2)) || { usage >&2; exit 2; }; destdir=$2; shift ;;
        --dry-run) dry_run=true ;;
        --help|-h) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

if [[ ! -f $script_dir/shell.qml ]]; then
    command -v git >/dev/null 2>&1 || { echo 'git is required to download LunaDash-Shell.' >&2; exit 1; }
    checkout=$(mktemp -d "${TMPDIR:-/tmp}/lunadash-shell.XXXXXXXX")
    trap 'rm -rf -- "$checkout"' EXIT
    git -c maintenance.auto=false clone --quiet --depth 1 --branch main "$repo_url" "$checkout"
    args=()
    $prefix_set && args+=(--prefix "$prefix")
    [[ -z $destdir ]] || args+=(--destdir "$destdir")
    $dry_run && args+=(--dry-run)
    "$checkout/install.sh" "${args[@]}"
    exit $?
fi

if $prefix_set; then
    [[ $prefix == /* ]] || { echo 'PREFIX must be an absolute path.' >&2; exit 2; }
    data_directory=${prefix%/}/share
else
    data_directory=${custom_data_home:-$HOME/.local/share}
    [[ $data_directory == /* ]] || { echo 'XDG_DATA_HOME must be an absolute path.' >&2; exit 2; }
fi
destination=${destdir%/}${data_directory%/}/lunadash/shell
[[ $destination == /* ]] || { echo 'DESTDIR and PREFIX must form an absolute path.' >&2; exit 2; }

if $dry_run; then
    printf 'Would install LunaDash Shell from %s to %s\n' "$script_dir" "$destination"
    exit 0
fi

parent=$(dirname -- "$destination")
install -d -m 0755 -- "$parent"
stage=$(mktemp -d "$parent/.lunadash-shell-stage.XXXXXXXX")
cleanup() { rm -rf -- "$stage"; }
trap cleanup EXIT
while IFS= read -r -d '' file; do
    relative=${file#"$script_dir"/}
    case "$relative" in
        *.qml|*.js|*.svg|*.png|*.jpg|*.jpeg|*.webp|*.gif|qmldir)
            install -D -m 0644 -- "$file" "$stage/$relative"
            ;;
    esac
done < <(find "$script_dir" -type f -print0)
[[ -f $stage/shell.qml ]] || { echo 'shell.qml is missing from the install set.' >&2; exit 1; }

rm -rf -- "$destination"
mv -- "$stage" "$destination"
trap - EXIT
printf 'Installed LunaDash Shell to %s\n' "$destination"
