#!/bin/env zsh

pluginPath="$HOME/.local/share/zap/plugins/portal/portal.plugin.zsh";

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
# source $portalScriptPath;

function _portalJump(){
  source $portalScriptPath;
  if [ -z $1 ]; then
    echo "echo 'provide a portal name.'";
    # return 1;
  fi

  portPath="";
  for key in ${(k)ports}; do
    betterKey="${key#\"}"
    betterKey="${betterKey%\"}"
    if [[ "$betterKey" == "$1" ]]; then
      portPath="$ports[$key]";
    fi
  done

  if [ -z $portPath ]; then
    echo "echo 'no such portal:' ${1}";
    # return 1;
  fi

  # echo "cd $portPath";
  cd $portPath;
}

function _portalCreate(){
  # sed -i '0,/-- ports --/{s|-- ports --|-- ports --\nports\['\""$1"\"'\]='"\"$2\""';|}' $portalScriptPath;
  echo "ports[\"$1\"]=\"$2\"" >> $portalScriptPath;
}

function _portalDelete(){
  sed -i '/^ports\[\"'"$1"'\"\]/d' $portalScriptPath;
}

function _portalList(){
  source $portalScriptPath;

  if [[ -z $1 ]]; then
    # for key in "${!ports[@]}"; do
    #   echo -e "\e[33m$key\e[0m ${ports[$key]}";
    # done
    for key in ${(k)ports}; do
      echo -e "\e[33m$key\e[0m $ports[$key]";
    done
  else
    portPath="";
    for key in ${(k)ports}; do
      betterKey="${key#\"}"
      betterKey="${betterKey%\"}"
      if [[ "$betterKey" == "$1" ]]; then
        portPath="$ports[$key]";
      fi
    done
    if [ -z $portPath ]; then
      echo "no such portal: $1";
      return 1;
    fi
    echo "$portPath";
  fi
}

function portal(){
  if [[ $1 == "create" ]]; then
    _portalCreate $2 $3;
  elif [[ $1 == "jump" ]]; then
    _portalJump $2
  elif [[ $1 == "delete" ]]; then
    _portalDelete $2
  elif [[ $1 == "list" ]]; then
    _portalList $2
  elif [[ $1 == "help" ]]; then
    echo "options: create (pc) | jump (pj) | delete (pd) | list (pl) | help (ph)";
  fi
}