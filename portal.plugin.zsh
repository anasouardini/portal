#!/bin/env sh

pluginPath="$HOME/.local/share/zsh/plugins/portal/portal.plugin.zsh";

# set aliases
function pc(){
  bash $pluginPath create $1 $(pwd);
}
function pj(){
  eval $(bash $pluginPath jump $1);
}
function pd(){
  bash $pluginPath $1;
}
function pl(){
  bash $pluginPath list $1;
}
function ph(){
  bash $pluginPath help;
}

# portalScriptPath="$(pwd)/${BASH_SOURCE[0]}";
# portalScriptPath="$HOME/.shconf/rc/tools/portal";
sharedPath="$HOME/.local/share";
portalScriptPath="${sharedPath}/portals";

## make sure portals exist
if [[ ! -d $sharedPath ]]; then
  mkdir -p $sharedPath;
fi
if [[ ! -f $portalScriptPath ]]; then
  touch $portalScriptPath;
  echo -e "declare -A ports" > $portalScriptPath;
fi

## source portals
source $portalScriptPath;

function portalJump(){
  if [ -z $1 ]; then
    echo "provide a portal name.";
    exit 1;
  fi
  path="${ports[$1]}";
  if [ -z $path ]; then
    echo "echo 'no such portal:' ${1}";
    exit 1;
  fi
  echo "cd $path";
}

function portalCreate(){
  # sed -i '0,/-- ports --/{s|-- ports --|-- ports --\nports\['\""$1"\"'\]='"\"$2\""';|}' $portalScriptPath;
  echo "ports[\"$1\"]=\"$2\"" >> $portalScriptPath;
}

function portalDelete(){
  sed -i '/^ports\[\"'"$1"'\"\]/d' $portalScriptPath;
}

function portalList(){
  if [[ -z $1 ]]; then
    for key in "${!ports[@]}"; do
      echo -e "\e[33m$key\e[0m ${ports[$key]}";
    done
  else
    path="${ports[$1]}";
    if [ -z $path ]; then
      echo "no such portal: $1";
      exit 1;
    fi
    echo "$path";
  fi
}

if [[ $1 == "create" ]]; then
  portalCreate $2 $3;
elif [[ $1 == "jump" ]]; then
  portalJump $2
elif [[ $1 == "delete" ]]; then
  portalDelete $2
elif [[ $1 == "list" ]]; then
  portalList $2
elif [[ $1 == "help" ]]; then
  echo "options: create (pc) | jump (pj) | delete (pd) | list (pl) | help (ph)";
fi
