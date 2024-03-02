#!/bin/bash

set -eo pipefail

get_os() {
	os="$(uname -s)"
	if [ "$os" = Darwin ]; then
		echo "macos"
	elif [ "$os" = Linux ]; then
		echo "linux"
	else
		error "unsupported OS: $os"
	fi
}

install_homebrew() {
	local rc_file
	rc_file=$(get_rc_file "$(basename "$SHELL")")

	if [ ! "$(command -v brew)" ]; then
		echo 'Installing homebrew...'
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

		# shellcheck disable=SC2016
		(
			echo
			echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
		) >>"$rc_file"
		eval "$(/opt/homebrew/bin/brew shellenv)"

		echo 'Done!'
	else
		echo '`homebrew` is already installed!'
	fi
}

get_rc_file() {
	local shell_name
	shell_name=$1

	case "$shell_name" in
	bash)
		printf "%s/.bashrc" "$HOME"
		;;
	zsh)
		printf "%s/.zshrc" "$HOME"
		;;
	fish)
		printf "%s/.config/fish/config.fish" "$HOME"
		;;
	*)
		printf "Unsupported shell: %s" "$shell_name"
		exit 1
		;;
	esac
}

build_mise_activate_cmd() {
	local mise_bin_path
	local shell_name
	local rc_file

	mise_bin_path="${MISE_INSTALL_PATH:-$HOME/.local/bin/mise}"
	shell_name=$(basename "$SHELL")
	rc_file=$(get_rc_file "$shell_name")

	case "$shell_name" in
	bash)
		# shellcheck disable=SC2016
		printf 'eval "$(%s activate bash)"' "$mise_bin_path"
		;;
	zsh)
		# shellcheck disable=SC2016
		printf 'eval "$(%s activate zsh)"' "$mise_bin_path"
		;;
	fish)
		printf '%s activate fish | source' "$mise_bin_path"
		;;
	*)
		printf "Unsupported shell: %s" "$shell_name"
		exit 1
		;;
	esac
}

write_mise_activate_to_rc() {
	local mise_bin
	local default_shell
	local rc_file
	local mise_activate_cmd

	mise_bin="$HOME/.local/bin/mise"
	default_shell=$(basename "$SHELL")
	rc_file=$(get_rc_file "$default_shell")
	mise_activate_cmd=$(build_mise_activate_cmd "$mise_bin" "$default_shell")

	# only append mise shell activation command to shell rc if it doesn't already exist
	touch "$rc_file" && grep -qxF "${mise_activate_cmd}" "$rc_file" || echo "$mise_activate_cmd" >>"$rc_file"
}

install_mise() {
	local mise_bin
	local default_shell
	local rc_file
	local mise_activate_cmd

	mise_bin="$HOME/.local/bin/mise"
	default_shell=$(basename "$SHELL")
	rc_file=$(get_rc_file "$default_shell")
	mise_activate_cmd=$(build_mise_activate_cmd "$mise_bin" "$default_shell")

	if [ ! "$(command -v mise)" ]; then
		echo 'Installing mise...'
		curl https://mise.run | sh
		echo 'Done!'
	else
		echo '`mise` is already installed!'
	fi

	write_mise_activate_to_rc "$default_shell"
}

install_python_build_deps() {
	echo 'Installing Python build dependencies...'
	if [ $(get_os) = 'macos' ]; then
		brew install openssl readline sqlite3 xz zlib tcl-tk make
	elif [ $(get_os) = 'linux' ]; then
		sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
			libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
			libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl
	fi
	echo 'Done!'
}

main() {
	if [ $(get_os) = 'macos' ]; then
		install_homebrew
	fi

	install_mise
	install_python_build_deps

	# add mise to PATH for duration of script
	export PATH="$HOME/.local/bin:$PATH"

	mise settings set experimental true

	# this setting is necessary to avoid issues with poetry missing symlinks
	# https://github.com/mise-plugins/mise-poetry/issues/5
	mise settings set python_compile 1

	# install python first, so that poetry uses the correct python version
	mise install -y python

	mise install -y
}

main
