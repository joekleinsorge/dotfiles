export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="/usr/local/opt/node@16/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="$HOME/.emacs.d/bin:$PATH"
export EDITOR="nvim"
export KUBE_EDITOR="nvim"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

eval "$(starship init zsh)"

autoload -U +X compinit && compinit
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
compdef kubecolor=kubectl
command -v kubecolor >/dev/null 2>&1 && alias kubectl="kubecolor"

alias brew='arch -arm64 brew install'
alias cp='cp -v -i'
alias rm='rm -i'
alias mv='mv -i'
alias usage='du -hs ./* | sort -h'
alias s='wezterm ssh'
alias brew="arch -arm64 brew"
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gac="ga && gc"
alias gap="ga && gc 'ci: commit' && gp"
alias gapf= "git commit --amend --no-edit && gp --force-with-lease"
alias gcc='echo -e "\e[1;32mfix:\e[0m a commit that fixes a bug."; echo -e "\e[1;36mfeat:\e[0m a commit that adds new functionality."; echo -e "\e[1;33mdocs:\e[0m a commit that adds or improves documentation."; echo -e "\e[1;35mtest:\e[0m a commit that adds unit tests."; echo -e "\e[1;31mperf:\e[0m a commit that improves performance, without functional changes."; echo -e "\e[1;34mchore:\e[0m a catch-all type for any other commits."'
alias gl="git log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%an%C(reset)%C(bold yellow)%d%C(reset) %C(dim white)- %s%C(reset)' --all"
alias ls="eza --long --classify --icons --git --group-directories-first --color=always -a"
alias sl="ls"
alias bat="bat --color=always"
alias nivm="nvim"
alias n="nvim"
alias py="python3"
alias k="kubectl"
alias pip="/usr/bin/pip3"
alias mkdir="mkdir -p"
alias path='echo $PATH | tr -s ":" "\n"'
alias notes="nvim ~/git/notes/vault"
alias ...="cd ../.."
alias dot="cd ~/git/dotfiles"
alias skill="ps -ef | fzf | awk '{print $2}' | xargs kill -9"
alias ytdlmp4="yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]' --merge-output-format mp4"
alias ytdlmp3="yt-dlp -x --audio-format mp3 --audio-quality 0"
# =======================================
# fh - browse firefox history
fh() {
  local cols sep profile_dir
  cols=$(( COLUMNS / 3 ))
  sep='{::}'
  
  # Search for places.sqlite and extract the directory path
  profile_dir=$(find /Users/$(whoami)/Library/Application\ Support/Firefox/Profiles -type f -name "places.sqlite" -exec dirname {} \; | head -n 1)

  # Update the path to the Firefox history file
  cp -f "$profile_dir/places.sqlite" /tmp/h

  sqlite3 -separator $sep /tmp/h \
    "SELECT substr(moz_places.title, 1, $cols), moz_places.url
     FROM moz_places
     JOIN moz_historyvisits ON moz_places.id = moz_historyvisits.place_id
     ORDER BY moz_historyvisits.visit_date DESC" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs open
}

# fb - browse firefox bookmarks
fb() {
  local cols sep profile_dir
  cols=$(( COLUMNS / 3 ))
  sep='{::}'

  # Search for places.sqlite and extract the directory path
  profile_dir=$(find /Users/$(whoami)/Library/Application\ Support/Firefox/Profiles -type f -name "places.sqlite" -exec dirname {} \; | head -n 1)

  # Update the path to the Firefox database file
  cp -f "$profile_dir/places.sqlite" /tmp/b

  sqlite3 -separator $sep /tmp/b \
    "SELECT substr(moz_bookmarks.title, 1, $cols), moz_places.url
     FROM moz_bookmarks
     LEFT JOIN moz_places ON moz_bookmarks.fk = moz_places.id
     WHERE moz_bookmarks.type = 1
     ORDER BY moz_bookmarks.dateAdded DESC" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs open
}


# Function to extract common archive formats
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.gz) tar -xzvf "$1" ;;
      *.tar.xz) tar -xJvf "$1" ;;
      *.tar.bz2) tar -xjvf "$1" ;;
      *.zip) unzip "$1" ;;
      *.rar) unrar x "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "Unsupported archive format." ;;
    esac
  else
    echo "File not found."
  fi
}

squash() {
  commit=$(git log --oneline | fzf | awk '{print $1}')
  if [ -n "$commit" ]; then
    git reset --soft $commit && git add -A && git commit
  else
    echo "Squash cancelled because no commit was selected."
  fi
}

glt() {
  git reflog show --pretty=format:'%gs ~ %gd' --date=relative | grep 'checkout:' | grep -oE '[^ ]+ ~ .*' | awk -F~ '!seen[$1]++' | head -n 10 | awk -F' ~ HEAD@{' '{printf("  \033[33m%14s: \033[37m %s\033[0m\n", substr($2, 1, length($2)-1), $1)}'
}

cherry() {
  commit=$(git log --pretty=format:"%h %s" --branches='*' -n 100 \
    | fzf --height "90%" --header "PLEASE CHOOSE A COMMIT TO CHERRY-PICK" --reverse --border --ansi --preview "git show --color=always {1}" \
    | awk '{print $1}')
  if [ -n "$commit" ]; then
    git cherry-pick $commit
  fi
}

gco() {
    branch=$(git branch --all \
      | fzf --height "90%" --header "PLEASE CHOOSE A BRANCH TO CHECKOUT" \
      | sed "s/remotes\/origin\///" | xargs)
    if [ -n "$branch" ]; then
      git checkout $branch
    fi
}

gwi() {
    issue=$(gh issue list | fzf --header "PLEASE SELECT AN ISSUE TO WORK ON" | awk -F '\t' '{ print $1 }')
    sanitized=$(gh issue view $issue --json "title" | jq -r ".title" | tr '[:upper:]' '[:lower:]' | tr -s -c "a-z0-9\n" "-" | head -c 60)
    branchname=$issue-$sanitized
    shortname=$(echo $branchname | head -c 30)
    if [[ ! -z "$shortname" ]]; then
        git fetch
        existing=$(git branch -a | grep -v remotes | grep $shortname | head -n 1)
        if [[ ! -z "$existing" ]]; then
            sh -c "git switch $existing"
        else
            bold=$(tput bold)
            normal=$(tput sgr0)
            echo "${bold}Please confirm new branch name:${normal}"
            vared branchname
            base=$(git branch --show-current)
            echo "${bold}Please confirm the base branch:${normal}"
            vared base
            git checkout -b $branchname origin/$base
            git push --set-upstream origin $branchname
        fi
    fi
}

k_sh() {
  local namespace pod
  namespace_pod=$(kubectl get pods --all-namespaces --no-headers | fzf +m --header="Select a Pod:" | awk '{print $1, $2}')
  if [ -n "$namespace_pod" ]; then
    read -r namespace pod <<< "$namespace_pod"
    kubectl exec -it -n "$namespace" "$pod" -- /bin/sh
  else
    echo "No pod selected or no pods available."
  fi
}


pods(){
  kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name}{"\n"}' | \
  fzf --preview="kubectl logs {2} --namespace {1} --all-containers" --preview-window=down:80%
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
