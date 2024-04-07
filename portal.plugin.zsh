#!/bin/env sh

# portalScriptPath="$(pwd)/${BASH_SOURCE[0]}";
portalScriptPath="$HOME/.shconf/rc/tools/portal";

declare -A ports;
# -- ports --
ports["vocaverse"]="/home/venego/home/dev/desktop/lang";
ports["usb"]="/media/usb";
ports["lang"]="/home/venego/home/dev/desktop/lang";
ports["resume"]="/home/venego/home/docs/resume";
ports["portfolio"]="/home/venego/home/dev/web/portfolio-projects/front/astro/portfolioSite";
ports["weblab"]="/home/venego/home/dev/web/lab";
ports["lab"]="/home/venego/home/dev/lab";
ports["smartteam"]="/home/venego/home/dev/web/portfolio-projects/full/smartTeam";
ports["snipshare"]="/home/venego/home/dev/web/portfolio-projects/full/snipshare";
ports["dbstudio"]="/home/venego/home/dev/web/db-studio";
ports["notes"]="/home/venego/home/notes";
ports["sy4"]="/home/venego/home/dev/web/automation/scrapeyard-v4";
ports["sy"]="/home/venego/home/dev/web/automation/scrapeyard";
ports["down"]="/home/venego/Downloads";
ports["random"]="/home/venego/home/random";
ports["config"]="/home/venego/.config";

function portalJump(){
  path="${ports[$1]}";
  echo "cd $path";
}

function portalCreate(){
  sed -i '0,/-- ports --/{s|-- ports --|-- ports --\nports\['\""$1"\"'\]='"\"$2\""';|}' $portalScriptPath;
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
else
  echo "options: create | jump | delete | list";
fi
