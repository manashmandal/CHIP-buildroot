
#!/usr/bin/env bash
#
# The MIT License (MIT)
#
# Copyright (c) 2015 Next Thing Co.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


# utility variables
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
reset=`tput sgr0`

error()
{
  # was an error passed to this function?
  if [ -z "$1" ]; then
    #if not, print a standard error
    echo "[${red}DEBUG ${yellow}@ ${green}$(date +"%T")${reset}] ${red}Error occurred!${reset}"
  else
    # if so, we can print the message in an error
    echo "[${red}DEBUG ${yellow}@ ${green}$(date +"%T")${reset}] ${red}$1${reset}"
  fi
  exit 1
}

# log function
function log {
  echo "[${cyan}INFO  ${yellow}@ ${green}$(date +"%T")${reset}] $1"
}

# marker function
function marker {
  log "${yellow}===== ${blue}$1 ${yellow}====="
}

marker "$0"


# handle debug flag
if [ ${DEBUG} == true ]; then
  function debug {
    echo "[${magenta}DEBUG ${yellow}@ ${green}$(date +"%T")${reset}] $1"
  }
  debug "Debugging enabled"
else
  function debug {
    return
  }
fi

# host detection
HOST=`uname`
if [[ "${HOST}" == "Darwin" ]]; then
  HOST="Darwin"
elif [[ "${HOST}" == "Linux" ]]; then
  HOST="Linux"
else
  error "Unknown OS: ${HOST}. Exiting..."
fi
debug "Host detected: ${HOST}"