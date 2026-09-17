case "$(uname -s)" in
  Darwin) is_macos=true ;;
  *) is_macos=false ;;
esac

if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
elif [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export PATH=$HOME/bin:/usr/local/bin:$PATH
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.local/share/nvim/mason/bin" ] && export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
[ -n "${HOMEBREW_PREFIX:-}" ] && [ -d "$HOMEBREW_PREFIX/opt/ruby/bin" ] && export PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH"
[ -n "${HOMEBREW_PREFIX:-}" ] && [ -d "$HOMEBREW_PREFIX/opt/openjdk/bin" ] && export PATH="$HOMEBREW_PREFIX/opt/openjdk/bin:$PATH"
export PATH="$HOME/.emacs.d/bin:$PATH"
export EDITOR="nvim"
export KUBE_EDITOR="nvim"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

autoload -U +X compinit && compinit
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
compdef kubecolor=kubectl
command -v kubecolor >/dev/null 2>&1 && alias kubectl="kubecolor"

alias cp='cp -v -i'
alias rm='rm -i'
alias mv='mv -i'
alias usage='du -hs ./* | sort -h'
if $is_macos; then
  alias s='ssh'
elif command -v wezterm >/dev/null 2>&1; then
  alias s='wezterm ssh'
fi
if $is_macos && [ "$(uname -m)" = "arm64" ]; then
  alias brew="arch -arm64 brew"
fi
alias t='tmux'
alias tl='tmux list-sessions'
alias tr='tmux source-file ~/.tmux.conf \; display-message "tmux config reloaded"'
alias tkill='tmux kill-session -t'
alias tkillall='tmux kill-server'
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gac="ga && gc"
alias gap="ga && gc 'ci: commit' && gp"
alias gapf="git commit --amend --no-edit && gp --force-with-lease"
alias gcc='echo -e "\e[1;32mfix:\e[0m a commit that fixes a bug."; echo -e "\e[1;36mfeat:\e[0m a commit that adds new functionality."; echo -e "\e[1;33mdocs:\e[0m a commit that adds or improves documentation."; echo -e "\e[1;35mtest:\e[0m a commit that adds unit tests."; echo -e "\e[1;31mperf:\e[0m a commit that improves performance, without functional changes."; echo -e "\e[1;34mchore:\e[0m a catch-all type for any other commits."'
alias gl="git log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%an%C(reset)%C(bold yellow)%d%C(reset) %C(dim white)- %s%C(reset)' --all"
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --long --classify --icons --git --group-directories-first --color=always -a"
elif command -v exa >/dev/null 2>&1; then
  alias ls="exa --long --classify --icons --git --group-directories-first --color=always -a"
fi
alias sl="ls"
alias bat="bat --color=always"
alias nivm="nvim"
alias n="nvim"
alias py="python3"
alias k="kubectl"
alias pip="python3 -m pip"
alias mkdir="mkdir -p"
alias path='echo $PATH | tr -s ":" "\n"'
alias notes="nvim ~/git/notes/vault"
alias ...="cd ../.."
alias dot="cd ~/git/dotfiles"
alias skill="ps -ef | fzf | awk '{print $2}' | xargs kill -9"
alias ytdlmp4="yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]' --merge-output-format mp4"
alias ytdlmp3="yt-dlp -x --audio-format mp3 --audio-quality 0"
if $is_macos; then
  alias mentat="limactl start --mount-only .:w & lima"
fi

tx() {
  tmux new-session -A -s "${1:-main}"
}

tp() {
  local session="${1:-${PWD:t}}"
  tmux new-session -A -s "$session"
}

tj() {
  local session
  session=$(tmux list-sessions -F '#S' 2>/dev/null | fzf --height 40% --reverse) || return
  tmux attach -t "$session"
}


# =======================================
if $is_macos; then
  # SQLite's backup API includes committed WAL data without leaving browser
  # databases behind. A subshell limits the cleanup trap to this invocation.
  _firefox_pick() (
    emulate -L zsh
    setopt pipefail
    local mode="$1" database selected url tmp query
    local -a databases
    databases=("$HOME"/Library/Application\ Support/Firefox/Profiles/*/places.sqlite(N))
    (( ${#databases} )) || { print -u2 'No Firefox profile found.'; return 1; }
    database="${databases[1]}"
    if (( ${#databases} > 1 )); then
      database=$(printf '%s\n' "${databases[@]}" | fzf --header='Select Firefox profile') || return
    fi
    tmp=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-firefox.XXXXXX") || return
    trap 'command rm -rf -- "$tmp"' EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM HUP
    # A fixed relative filename avoids quoting arbitrary paths in SQLite commands.
    (cd "$tmp" && sqlite3 -readonly "$database" '.timeout 3000' '.backup places.sqlite') || return
    if [[ "$mode" = history ]]; then
      query='SELECT DISTINCT url FROM moz_places WHERE last_visit_date IS NOT NULL ORDER BY last_visit_date DESC;'
    else
      query='SELECT DISTINCT p.url FROM moz_bookmarks b JOIN moz_places p ON p.id=b.fk WHERE b.type=1 ORDER BY b.dateAdded DESC;'
    fi
    selected=$(sqlite3 "$tmp/places.sqlite" "$query" | fzf --multi --header="Firefox $mode") || return
    while IFS= read -r url; do
      case "$url" in http://*|https://*) open "$url" ;; esac
    done <<< "$selected"
  )
  fh() { _firefox_pick history; }
  fb() { _firefox_pick bookmarks; }
fi


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
  emulate -L zsh
  local selection commit
  [[ -z "$(git status --porcelain)" ]] || { print -u2 'Commit or stash changes before squashing.'; return 1; }
  selection=$(git log --format='%h %s' | fzf --header='Select the base commit to keep; squash commits AFTER it') || return
  commit=${selection%% *}
  [[ -n "$commit" ]] || return 1
  git merge-base --is-ancestor "$commit" HEAD || return
  [[ "$(git rev-parse "$commit")" != "$(git rev-parse HEAD)" ]] || { print -u2 'No commits after that base.'; return 1; }
  git reset --soft "$commit" && git commit
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
    emulate -L zsh
    local branch name
    branch=$(git for-each-ref --format='%(refname)' refs/heads refs/remotes \
      | grep -v '/HEAD$' | fzf --header='Select a branch') || return
    case "$branch" in
      refs/heads/*) git switch -- "${branch#refs/heads/}" ;;
      refs/remotes/*)
        name=${branch#refs/remotes/}
        name=${name#*/}
        if git show-ref --verify --quiet "refs/heads/$name"; then
          git switch -- "$name"
        else
          git switch --track -- "${branch#refs/remotes/}"
        fi ;;
    esac
}

gwi() {
    emulate -L zsh
    setopt pipefail
    local selection issue title sanitized branchname base
    selection=$(gh issue list | fzf --header='Select an issue') || return
    issue=${selection%%$'\t'*}
    [[ "$issue" = <-> ]] || return 1
    title=$(gh issue view "$issue" --json title --jq .title) || return
    sanitized=$(printf '%s' "$title" | LC_ALL=C tr '[:upper:]' '[:lower:]' | LC_ALL=C tr -cs 'a-z0-9' '-')
    branchname="$issue-${sanitized[1,60]}"
    vared -p 'Branch name: ' branchname || return
    git check-ref-format --branch "$branchname" >/dev/null || return
    if git show-ref --verify --quiet "refs/heads/$branchname"; then
      git switch -- "$branchname"
      return
    fi
    git fetch origin || return
    if git show-ref --verify --quiet "refs/remotes/origin/$branchname"; then
      git switch --track -- "origin/$branchname"
      return
    fi
    base=$(git branch --show-current) || return
    vared -p 'Base branch on origin: ' base || return
    git check-ref-format --branch "$base" >/dev/null || return
    git switch -c "$branchname" "refs/remotes/origin/$base" || return
    git push --set-upstream origin "$branchname"
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

teach-me() {
  emulate -L zsh
  set -u

  TEACH_ME_CWD="$PWD" \
  TEACH_ME_TTY="$(tty 2>/dev/null || true)" \
  TEACH_ME_LAST_CMD="$(fc -ln -1 2>/dev/null | sed -e 's/^[[:space:]]*//' || true)" \
  "$HOME/git/notes/teach-me" "$@"
}
alias tm='teach-me'



pods(){
  kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name}{"\n"}' | \
  fzf --preview="kubectl logs {2} --namespace {1} --all-containers" --preview-window=down:80%
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
