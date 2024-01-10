#!/bin/bash
# check_for_podman_install_if_not_exists () {
#   if ! command -v podman &> /dev/null 
#   then
#     echo '=============INSTALLING PODMAN==============='
#     echo 'Podman could not be found on the current system. Installing...'

#     brew install podman

#     if [ $? != 0 ]
#     then
#       echo 'Failed to install podman. Ensure that you are on MacOS with the latest version of homebrew installed.'
#       exit 1
#     fi

#     podman machine init

#     if [ $? != 0 ]
#     then
#       echo 'FATAL: Failed to initialize podman machine. Please check the error messages.'
#       exit 1
#     fi

#     podman machine start
#     if [ $? != 0 ]
#     then
#       echo 'FATAL: Failed to initialize podman machine. Please check the error messages.'
#       exit 1
#     fi
#   fi
# }

# Function to check if last command failed
check_for_failure () {
  if [ $? != 0 ] 
  then
    echo "FATAL: Failed in $1. Please check the error messages"
    exit 1
  fi
}


# Function to check if homebrew is installed
check_for_homebrew () {
  if ! command -v brew &> /dev/null
  then
    echo 'Homebrew is not installed. Installing...'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ $? != 0 ] 
    then
      echo 'FATAL: Failed to install homebrew. Please check the error messages or install manually from https://brew.sh'
      exit 1
    fi
  fi
  echo 'CHECK_FOR_HOMEBREW succeeded: Homebrew is installed.'
}

# Function to download colima
check_for_colima () {
  if ! command -v colima &> /dev/null
  then
    echo 'Colima is not installed. Installing through brew...'
    brew install colima;
    if [ $? != 0 ]
    then
      echo 'FATAL: Failed to install colima. Ensure that you have homebrew installed or install it manually.'
      exit 1
    fi
  fi
  brew services start colima;
  echo 'CHECK_FOR_COLIMA succeeded: Colima is installed.'
}

check_for_rosetta_2 () {
  if ! /usr/bin/pgrep -q oahd
  then
    echo 'Rosetta 2 is not installed. Installing...'
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    if [ $? != 0 ]
    then
      echo 'FATAL: Failed to install Rosetta 2. Install it manually.'
      exit 1
    fi
  fi
  if ! /usr/bin/pgrep -q oahd
  then
    echo 'FATAL: Failed to install Rosetta 2. Install it manually.'
    exit 1
  fi
  echo 'CHECK_FOR_ROSETTA_2 succeeded: Rosetta 2 is installed'
}

check_ios_version () {
  local IOS_VERSION=$(sw_vers -productVersion) 
  local regex='([0-9]+)\.'

  [[ $IOS_VERSION =~ $regex ]]

  local IOS_BASE_VERSION=$((${BASH_REMATCH[1]}))

  if [ $IOS_BASE_VERSION -lt 14 ]
  then
    echo 'Detected your iOS version as '$IOS_BASE_VERSION'. Please ensure that your iOS is updated to at least 14.1'
  fi
  local regex2='[0-9]+.([0-9]+)'

  [[ $IOS_VERSION =~ $regex2 ]]
  local IOS_SECOND_VERSION=$((${BASH_REMATCH[1]})) 

  if [ $IOS_SECOND_VERSION -lt 1 ]
  then
    echo 'Detected your iOS version as '$IOS_BASE_VERSION\.$IOS_SECOND_VERSION'. Please ensure that your iOS is updated to at least 14.1'
  fi

  echo 'IOS_VERSION_CHECK SUCCEEDED: Version '$IOS_BASE_VERSION\.$IOS_SECOND_VERSION' is >= 14.1.'

}

start_colima_instance () {
  echo 'Starting Colima Instance...'
  colima start --arch aarch64 --vm-type=vz --vz-rosetta 

  if [ $? != 0 ]
  then
    echo 'FATAL: Failed to initialize colima machine. Please ensure that you can run "colima start --arch aarch64 --vm-type=vz --vz-rosetta"'
    exit 1
  fi
}

create_fixed_docker_builder () {
  echo 'Create fixed docker_builder...'
  ssh colima 'docker buildx rm'
  ssh colima 'docker buildx create --name fixed_builder --driver-opt 'image=moby/buildkit:v0.12.1-rootless' --bootstrap --use'
  check_for_failure CREATE_FIXED_DOCKER_BUILDER
}

build_docker_image () {
  echo 'Building docker instance...'
  ssh colima "docker build --platform linux/amd64 $(pwd) -t dev-image"
  check_for_failure BUILD_DOCKER_IMAGE
  ssh colima "echo 'some_dummy_line' >> ~/.bashrc"
}

set_aliases () {
  chmod +x ./restartdevinstance
}

# some_random_func () {
#   echo '=============BUILDING CONTAINER==============='
#   podman build --format docker . -t dev-image --no-cache
#   if [ $? != 0 ]
#   then
#     echo 'Failed to build the podman(docker) image. Please retry this command\npodman build --format docker . -t dev_instance\n\tIf this fails to work tag a --no-cache at the end of it.'
#     exit 1
#   fi

#   echo '=============BUILDING CONTAINER WAS SUCCESSFUL=============='
#   echo 'It is now recommended to add these aliases to your ~/.bashrc or ~/.zshrc to make your dev environment easy to use:'
#   echo "alias devbash='$(cat ./devbash)'"
#   echo "alias restartdevinstance='$(cat ./restartdevinstance)'"
#   echo "AFTER YOU DO THIS source the file. ex: source ~/.bashrc - this enacts the changes. If you want to skip this step you can,
#   and you can simply use ./devbash and ./restartdevinstance from this folder instead."
# }
#   echo "Once you've done that, you can simply type 'restartdevinstance' into your CLI to start the machine and mount whichever directory you call it in. To get inside in the future, simply type devbash. Inside you'll find that there's Lunar Vim (a neovim config) preinstalled, along with quite a bit of tooling. Visit the lunar vim website to find out more about lunar vim, or play around with it with the lvim command. Ensure that you installed a Nerd Font as instructed in README.md"

check_ios_version
check_for_homebrew
check_for_colima
check_for_rosetta_2
start_colima_instance
create_fixed_docker_builder
build_docker_image
