#!/bin/env bash

# pluginPath="$HOME/.local/share/zap/plugins/portal/portal.plugin.zsh";

# portalScriptPath="$(pwd)/${BASH_SOURCE[0]}";
# portalScriptPath="$HOME/.shconf/rc/tools/portal";
sharedPath="$HOME/.local/share";
portalScriptPath="${sharedPath}/portals";
portalHistoryPath="${sharedPath}/portals-history";

## make sure portals exist
if [[ ! -d $sharedPath ]]; then
  mkdir -p $sharedPath;
fi
if [[ ! -f $portalScriptPath ]]; then
  touch $portalScriptPath;
  echo -e "declare -A ports" > $portalScriptPath;
fi
if [[ ! -f $portalHistoryPath ]]; then
  touch $portalHistoryPath;
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
  if [[ $1 == "history" ]];then
    # echo "history +=(\"$2\")" >> $portalScriptPath;
    echo -e $2 >> $portalHistoryPath
  else
    # sed -i '0,/-- ports --/{s|-- ports --|-- ports --\nports\['\""$1"\"'\]='"\"$2\""';|}' $portalScriptPath;
    echo "ports[\"$1\"]=\"$2\"" >> $portalScriptPath;
  fi
}

function _portalDelete(){
  if [[ -z $1 ]]; then
    sed -i '/^ports\[.*/g' $portalScriptPath;
  else
    sed -i '/^ports\[\"'"$1"'\"\]/d' $portalScriptPath;
  fi
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
    _portalCreate $2 $(pwd);
  elif [[ $1 == "jump" ]]; then
    _portalJump $2
  elif [[ $1 == "delete" ]]; then
    _portalDelete $2
  elif [[ $1 == "empty" ]]; then
    _portalDelete
  elif [[ $1 == "list" ]]; then
    _portalList $2
  elif [[ $1 == "help" ]]; then
    echo "options: create (pc) | jump (pj) | delete (pd) | empty (pe) | list (pl) | help (ph)";
  fi
}

# TODO: maybe ask the user if he wants the aliases?

# aliases
alias ph="portal help";
alias pc="portal create";
alias pj="portal jump";
alias pd="portal delete";
alias pe="portal empty";
alias pl="portal list";
alias plh="command cat ${portalHistoryPath}";

function cd(){
  if [[ ! -z $1 && ! -d $1 ]];then
    # guess the path
    guessedPaths=$(command cat $portalHistoryPath | command fzf -f $1)
    if [[ ! -z $guessedPaths ]]; then
      firstGuessedPath=$(echo $guessedPaths | command head -n 1)
      # echo $firstGuessedPath
      # echo "path found in history.";
      builtin cd $firstGuessedPath;
    else
      echo "path is not valid and it wasn't found in history of portals.";
      echo "portals-history at ${portalHistoryPath}";
    fi
  else
    targetPath=$(realpath ~); # if it's empty, set it to home
    if [[ ! -z $1 ]]; then
      targetPath=$(realpath $1 2> /dev/null);
    fi

    found=$(cat $portalHistoryPath | grep -x "${targetPath}");
    if [[ -z $found ]]; then
      # store the path
      # echo "new path: " $targetPath;
      _portalCreate "history" $targetPath;
    fi

    builtin cd $targetPath;
  fi
}