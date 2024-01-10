#!/bin/bash
check_for_podman_install_if_not_exists () {
  if ! command -v podman &> /dev/null 
  then
    echo '=============INSTALLING PODMAN==============='
    echo 'Podman could not be found on the current system. Installing...'

    brew install podman

    if [ $? != 0 ]
    then
      echo 'Failed to install podman. Ensure that you are on MacOS with the latest version of homebrew installed.'
      exit 1
    fi

    podman machine init

    if [ $? != 0 ]
    then
      echo 'FATAL: Failed to initialize podman machine. Please check the error messages.'
      exit 1
    fi

    podman machine start
    if [ $? != 0 ]
    then
      echo 'FATAL: Failed to initialize podman machine. Please check the error messages.'
      exit 1
    fi
  fi
}

# Function to check if homebrew is installed
check_for_homebrew () {
  if ! command -v brew &> /dev/null
  then
    echo 'FATAL: Homebrew is not installed. Please install homebrew from: https://brew.sh'
    exit 1
  fi
}

# Function to download colima
download_colima_if_not_exists () {
  if ! command -v colima &> /dev/null
  then
    brew install colima;
    if [ $? == 0 ]
    then
      echo 'FATAL: Failed to install colima. Ensure that you have homebrew installed or install it manually.'
      exit 1
    fi

  fi
}

check_for_rosetta_2 () {
  echo 'do_something'  
}

check_ios_version () {
  local IOS_VERSION=$(sw_vers -productVersion) 
  echo $IOS_VERSION
  local regex='/instances/([0-9]+)\.'
  [[ $IOS_VERSION =~ $regex ]]
  echo ${BASH_REMATCH[1]}
}

some_random_func () {
  echo '=============BUILDING CONTAINER==============='
  podman build --format docker . -t dev-image --no-cache
  if [ $? != 0 ]
  then
    echo 'Failed to build the podman(docker) image. Please retry this command\npodman build --format docker . -t dev_instance\n\tIf this fails to work tag a --no-cache at the end of it.'
    exit 1
  fi

  echo '=============BUILDING CONTAINER WAS SUCCESSFUL=============='
  echo 'It is now recommended to add these aliases to your ~/.bashrc or ~/.zshrc to make your dev environment easy to use:'
  echo "alias devbash='$(cat ./devbash)'"
  echo "alias restartdevinstance='$(cat ./restartdevinstance)'"
  echo "AFTER YOU DO THIS source the file. ex: source ~/.bashrc - this enacts the changes. If you want to skip this step you can,
  and you can simply use ./devbash and ./restartdevinstance from this folder instead."
  echo "Once you've done that, you can simply type 'restartdevinstance' into your CLI to start the machine and mount whichever directory you call it in. To get inside in the future, simply type devbash. Inside you'll find that there's Lunar Vim (a neovim config) preinstalled, along with quite a bit of tooling. Visit the lunar vim website to find out more about lunar vim, or play around with it with the lvim command. Ensure that you installed a Nerd Font as instructed in README.md"
}

check_ios_version
