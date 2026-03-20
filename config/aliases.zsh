# My custom aliases for zsh

# Utility
alias ll="ls -lah"
alias la="ls -a"
alias oldtop="/usr/bin/top"

# Navigation
alias ..="cd ../"
alias ..l="cd ../ && ll"
alias ...="cd ../.."
alias dev="cd ~/dev"
alias dd="cd ~/dev"
alias d="cd ~/dev && cd "
alias md="mkdir "
alias sshdir="cd ~/.ssh"
alias devdir="cd ~/dev"

# Network
alias pg="echo 'Pinging Google' && ping www.google.com"
alias myip="curl http://ipecho.net/plain; echo"

# System
alias usage="du -h -d1"
alias runp="lsof -i "

# Shell config
alias zshrc="nano ~/.zshrc"
alias update="source ~/.zshrc"
alias topten="history | sort -rn | head"
alias dirs="dirs -v | head -10"

# Editor
alias c="code ."

# SSH
alias adssh="ssh-add ~/.ssh/github"

# npm aliases
alias ni="npm install"
alias nrd="npm run dev"
alias nrs="npm run start -s --"
alias nrb="npm run build -s --"
alias nrt="npm run test -s --"
alias nrtw="npm run test:watch -s --"
alias nrv="npm run validate -s --"
alias rnm="rm -rf node_modules"
alias npm-update="npx npm-check -u"

# yarn aliases
alias yai="yarn install"
alias yab="yarn build"
alias yal="yarn lint:fix"
alias yac="yarn commit"
alias yas="yarn start"
alias yasb="yarn storybook:start"
alias yat="yarn test"
alias yatw="yarn test:watch"
alias flush-nm="rm -rf node_modules && yarn install && echo Yarn install is done"

# git aliases
alias gc="git checkout "
alias gcm="git checkout master"
alias gs="git status"
alias gpull="git pull"
alias gf="git fetch"
alias gfa="git fetch --all"
alias gpush="git push"
alias gpushf="git push -f"
alias gd="git diff"
alias ga="git add ."
alias gb="git branch"
alias gbr="git branch remote"
alias gfr="git remote update"
alias gbn="git checkout -B "
alias grf="git reflog"
alias grh="git reset HEAD~"
alias gac="git add . && git commit -a -m "
alias gsu="git push --set-upstream origin "
alias glog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"

# gitmoji aliases
alias gmc="gitmoji -c"

# markdown
alias mdp="glow"           # preview markdown file: mdp README.md
alias mdl="glow -p"        # paged view (less-style): mdl README.md

# docker aliases
alias dockerstop="docker compose stop"
alias dockerrestart="docker compose restart"
alias dockerup="docker compose up -d"
alias dockerrm="docker compose rm --all"
alias dockerdown="docker compose down"
