# pluginPath="$HOME/.local/share/zap/plugins/portal/portal.plugin.zsh";

whatShell='';
if [ -n "$BASH_VERSION" ]; then
    whatShell="bash";
elif [ -n "$ZSH_VERSION" ]; then
    whatShell="zsh";
else
    echo "unknown shell, use either bash or zsh";
    return 0;
fi

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

function _portalExecute(){
  targetCommand=$1
  targetPath=$2

  source $portalScriptPath;
  if [ -z $1 ]; then
    echo "echo 'provide a portal name.'";
    # return 1;
  fi

  portalPath="";
  for key in ${(k)ports}; do
    betterKey="${key#\"}"
    betterKey="${betterKey%\"}"
    if [[ "$betterKey" == "$targetPath" ]]; then
      portalPath="$ports[$key]";
    fi
  done

  if [ -z $portPath ]; then
    echo "echo 'no such portal:' ${targetPath}";
    # return 1;
  fi

  if [[ $targetCommand == "cd" ]]; then
    builtin cd $portalPath;
    return 0;
  fi
  command $targetCommand $portalPath;
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

function _portalDynamic(){
  targetCommand=$1;
  targetPath=$2;
  if [[ $targetPath == "-" ]]; then
    builtin cd -;
    return 0;
  fi

  if [[ ! -z $targetPath && ! -d $targetPath ]];then
    # guess the path
    guessedPaths=$(command cat $portalHistoryPath | command fzf -f $targetPath);
    if [[ $targetCommand == 'cdc' ]];then
      guessedPaths=$(command cat $portalHistoryPath | command fzf -f "$(pwd) ${targetPath}")
    fi

    if [[ ! -z $guessedPaths ]]; then
      firstGuessedPath=$(echo $guessedPaths | command head -n 1)
      # echo $firstGuessedPath
      # echo "path found in history.";
      if [[ $targetCommand == "cd" || $targetCommand == "cdc" ]]; then
        builtin cd $firstGuessedPath;
      else
        command $targetCommand $firstGuessedPath;
      fi
    else
      echo "path is not valid and it wasn't found in history of portals.";
      echo "portals-history at ${portalHistoryPath}";
    fi
    return 0;
  fi

  # this is when the path is valid (no fuzzy guessing)
  parsedTargetPath=$(realpath ~); # if it's empty, set it to home
  if [[ ! -z $targetPath ]]; then
    parsedTargetPath=$(realpath $targetPath 2> /dev/null);
  fi

  found=$(cat $portalHistoryPath | grep -x "${parsedTargetPath}");
  if [[ -z $found ]]; then
    # store the path
    # echo "new path: " $parsedTargetPath;
    _portalCreate "history" $parsedTargetPath;
  fi

  if [[ $targetCommand == "cd" || $targetCommand == "cdc" ]]; then
    builtin cd $parsedTargetPath;
    return 0;
  fi
  command $targetCommand $parsedTargetPath;
}

function interactivePortal(){
  targetLine="";
  if [[ $whatShell == "bash" ]];then
    targetLine=$BASH_COMMAND;
  elif [[ $whatShell == "zsh" ]];then
    targetLine=$BUFFER;
  fi

  if [[ ! $targetLine == "cd "* ]]; then
    return 0;
  fi

  targetLine=$(echo $targetLine | sed 's/cd //');

  chosenPath=$(command cat $portalHistoryPath | command fzf --query="$targetLine");

  export BUFFER="cd $chosenPath";
  zle accept-line

  # xdotool type $chosenPath;
}

function _portalBind(){
  targetCommand=$1;
  targetAlias=$2;
  
  if [[ -z $targetAlias ]]; then
    echo "provide an alias";
    return 1;
  fi

  if [[ $targetAlias == *" "* ]]; then
    echo "alias must not contain spaces";
    return 1;
  fi

  if [[ -z $targetCommand ]]; then
    echo "provide a command";
    return 1;
  fi

  cmdList=("help" "list" "create" "jumpt" "remove" "empty" "dynamic");
  if [[ ! " ${cmdList[*]} " =~ " ${targetCommand} " ]]; then
    echo "echo 'unknown command: ${targetCommand}'";
    return 1;
  fi

  echo "alias ${targetAlias}='portal ${targetCommand}'" >> $portalScriptPath;
  source $portalScriptPath;
}

# todo: add "px", execute command on the selected portal
helpMenu=(
  "Usage:"
  " "
  "    portal [command] [path/option]"
  " "
  "commands:"
  " "
  "    help           prints this help menu"
  "    bind           add an alias for a command: 'bind [command] [alias]'"
  "                   e.g: 'portal bind create c' sets 'alias pc='portal create''"
  " "
  "    ====== Implicit:"
  " "
  "      Portal implicitly tracks all paths you visit and then figures out which"
  "      one you want to visit if you type an invalid/vague path next time."
  " "
  "      cd             a default alias so that you don't have to constantly"
  "                     think about the tool while browsing your files"
  "                     long version: 'portal cd [path/guess]'"
  "      cdh            lists the history of paths that Portal collected"
  "      dynamic        dynamically figures out the path from a vague guess."
  "                     use 'bind' to set an alias for it like 'pd'."
  "                     'pd [cmd] [guess/path]' runs the [cmd] and passes"
  "                     the [guess/path] to it as an argument."
  " "
  "                     e.g: 'pd stat fig' runs 'stat' on '~/.config'"
  "                     note: 'pd cd fig' is already under the alias 'cd',"
  "                     so you can just run 'cd fig' as you would normally"
  " "
  "    ====== Explicit:"
  " "
  "      You might want to directly go to a path using a certain name that you"
  "      explicitly chose, in which case you can use the explicit method."
  " "
  "      create         adds current path to db with the provided name"
  "      jump           jumps to the provided portal name"
  "      remove         removes the provided portal name"
  "      empty          removes all portals"
  "      list           lists all portals, unless you pass a portal name"
  "                     in which case it only lists that portal"
  "                     e.g: 'du -h \$(portal list config)'"
  "      execute        runs command on the selected portal"
  "                     e.g: 'portal execute tree [portal]' runs 'tree' on"
  "                     the selected portal"
  "                     'portal jump' runs 'portal execute cd [portal]'"
);

function portal(){
  if [[ $1 == "create" ]]; then
    _portalCreate $2 $(pwd);
  elif [[ $1 == "jump" ]]; then
    _portalExecute "cd" $2
  elif [[ $1 == "remove" ]]; then
    _portalDelete $2
  elif [[ $1 == "empty" ]]; then
    _portalDelete
  elif [[ $1 == "list" ]]; then
    _portalList $2
  elif [[ $1 == "execute" ]]; then
    _portalExecute $2 $3
  elif [[ $1 == "bind" ]]; then
    _portalBind $2 $3
  elif [[ $1 == "dynamic" ]]; then
    _portalDynamic $2 $3
  elif [[ $1 == "help" ]]; then
    for line in $helpMenu; do
      echo $line;
    done
  else
    for line in $helpMenu; do
      echo $line;
    done
  fi
}

# aliases for manual teleportation
# alias ph="portal help";
# alias pc="portal create";
# alias pj="portal jump";
# alias pr="portal remove";
# alias pe="portal empty";
# alias pl="portal list";

# aliases for dynamic teleportation
# alias pd="portal dynamic";

# special alias for cd (dynamic teleportation)
alias cdh="command cat ${portalHistoryPath}";
alias cd="portal dynamic 'cd'";
alias cdc="portal dynamic 'cdc'";

if [[ $whatShell == "zsh" ]]; then
  zle -N interactivePortal;
  bindkey '^p' interactivePortal;
elif [[ $whatShell == "bash" ]]; then
  #* bash is full of quircks in this regard.
  # bind -x '"\C-p":"interactivePortal\n"';
fi