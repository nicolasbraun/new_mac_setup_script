#      ████                            ██   ██
#     ░██░                            ░██  ░░
#    ██████ ██   ██ ███████   █████  ██████ ██  ██████  ███████   ██████
#   ░░░██░ ░██  ░██░░██░░░██ ██░░░██░░░██░ ░██ ██░░░░██░░██░░░██ ██░░░░
#     ░██  ░██  ░██ ░██  ░██░██  ░░   ░██  ░██░██   ░██ ░██  ░██░░█████
#     ░██  ░██  ░██ ░██  ░██░██   ██  ░██  ░██░██   ░██ ░██  ░██ ░░░░░██
#     ░██  ░░██████ ███  ░██░░█████   ░░██ ░██░░██████  ███  ░██ ██████
#     ░░    ░░░░░░ ░░░   ░░  ░░░░░     ░░  ░░  ░░░░░░  ░░░   ░░ ░░░░░░
#

#########################################
# Make a directory and cd into it       #
#########################################
mkd() {
	mkdir -p -- "$@" && cd -- "$@"
}

#########################################
# Go to the root of git directory       #
#########################################
root() {
	while ! [ -d .git ]; do cd ..; done
}

#########################################
# Grep for a running process            #
#########################################
pa() {
	ps aux | rg "$*"
}

#########################################
# Grep for a history entry              #
#########################################
ha() {
	history | rg "$*"
}

########################################
# Open a file if passed one, otherwise #
# open the current directory           #
#######################################
o() {
	open "${1:-.}"
}

#########################################
# 1Password                             #
#########################################
1p() {
	eval $(op signin my)
}

########################################
# Dash                                 #
########################################
dash() {
	open "dash://${1}"
}

########################################
# Get public IP address                #
########################################
ip() {
	ip=$(curl -s ifconfig.me)
	echo "$ip"
	echo "$ip" | pbcopy
}

########################################
# Run a git hook                       #
########################################
hook() {
	local current_dir=$(pwd)

	root

	if [ -f ".git/hooks/${1}" ]; then
		. ".git/hooks/${1}"
	fi

	cd "${current_dir}"
}

_hook() { root && compadd "${(@)${(f)$(ls .git/hooks | grep -v "\.sample")}}"; }
compdef _hook hook
compdef _hook git-hook


#########################################
# Move target $1 to $1.bak              #
#                                       #
# https://github.com/shazow/dotfiles/   #
#########################################
bak() {
	declare target=$1;
	if [[ "${target:0-1}" = "/" ]]; then
		target=${target%%/}; # Strip trailing / of directories
	fi
	mv -v $target{,.bak}
}

#########################################
# Move target $1.bak to $1              #
#                                       #
# https://github.com/shazow/dotfiles/   #
#########################################
unbak() {
	declare target=$1;
	if [[ "${target:0-1}" = "/" ]]; then
		# Strip trailing / of directories
		target="${target%%/}"
	fi

	if [[ "${target:0-4}" = ".bak" ]]; then
		mv -v "$target" "${target%%.bak}"
	else
		echo "No .bak extension, ignoring: $target"
	fi
}

_unbak() { compadd "${(@)$(ls *.bak)}" }
compdef _unbak unbak


#########################################
# Get battery percent                   #
#########################################
battery() {
	local batt=$(pmset -g batt)
	batt=($(echo "${batt}" | tr '	' '\n'))
	local percent="${batt[8]}"
	percent=${percent//\;/}

	echo "${percent}"
}

#########################################
# Purge Cloudflare cache                #
#########################################
purge-cloudflare-cache() {
	local zone=$(api cf zones | \
	jq -r '.result[] | [.name, .id] | flatten | @csv' | \
	sed 's/"//g' | \
	sed 's/,/ /g' | \
	fzf --query="${1}" --select-1 --no-multi --cycle --layout=reverse --height=25 --prompt='' --with-nth 1 --delimiter=" " --border=none --color=dark --color="gutter:-1")

	local zone_id=$(echo "${zone}" | cut -d' ' -f2)
	local zone_name=$(echo "${zone}" | cut -d' ' -f1)

	local diditwork=$(curl -X -sSL POST "https://api.cloudflare.com/client/v4/zones/${zone_id}/purge_cache" \
	-H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
	-H "Content-Type:application/json" \
	--data '{"purge_everything":true}' | \
	jq -r '.success')

	if [[ "${diditwork}" = "true" ]]; then
		echo "$(tput setaf 2)✓ Purged Cloudflare cache for ${zone_name} (${zone_id})$(tput sgr0)"
	else
		echo "᙮ Failed to purge Cloudflare cache for ${zone_name} (${zone_id})"
	fi
}