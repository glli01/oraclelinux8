# Oracle Linux 8 Dev Environment
Last updated: January 23, 2024

## Introduction
This project started because node-oracledb v5.5.0 on the oracle artifactory does not install on M1 macs.
As a move towards portable dev environments, this is meant to allow me and others (with a lot of dev tooling that I use) to
run and install the same dev environment across machines. So far, it is working on windows and mac.

This includes a lot of packages that are widely used in javascript with some python and rust.
These include (but this list will likely change - you can check the dockerfile yourself): 
git, rsync, jq, make, nano, vim, lsof, unzip, zip, python3.11, cargo, sudo, docker, oracle-instantclient-release-el8, fontconfig, tmux

## Installation
The only system on-which this has taken setup other than building the image and running the docker container (you just need the dockerfile)
is the M1 mac. This is because x86 architectures were quite difficult to virtualize on a m1 mac. Now, however, with rosetta 2 and lima support
for it, we can add a couple of steps to setup rosetta, colima and docker buildx to allow this to work.  (All of the details are in the install.sh script).

As for the installation it is meant to be quite easy, clone this repository and then run the `install.sh` script. Then make a few changes.
### Step 1. Clone repository
```bash
git clone https://github.com/glli01/oraclelinux8.git
cd oraclelinux8
```
(or just download the zip and go into that directory)

### Step 1b. (Optional) Configure the restartdockerinstance command
The restartdockerinstance command should be configured to ensure that your container runs as you'd like.
If you expect to use dind (docker in docker) or containers on the container, you should add a -v tag and --privileged into the command.
```bash
-v <PATH_TO_FOLDER_ON_LOCAL>:/root/shared --privileged
```

It should look something like this.
```bash
ssh colima 'sed "$(( $(wc -l <  ~/.bashrc)-1+1 )),$ d" ~/.bashrc > .bashrc.txt; mv .bashrc.txt ~/.bashrc'; ssh colima 'echo "docker run -it --platform linux/amd64 --privileged -v <PATH_TO_FOLDER_ON_LOCAL>:/root/shared --name dev_instance dev-image /bin/bash " >> ~/.bashrc'; colima ssh;
```

I would suggest at least adding in the -v file so that you can use a local editor like VS Code if you do not like using neovim to edit.
This mounts a folder from your local machine onto the docker container.
Privileged runs the container as rootful, which has quite a few consequences, which you should consider yourself. Personally, I do include this as it is
necessary for docker in docker.

### Step 2. Run the install script.
```bash
./install.sh
```
This install script is meant to setup all of your dependencies if you don't have them as well as add in some fixes.

### Step 3. Setup your environment and aliases
After the dockerfile finishes running, the last step is to run restartdockerinstance. This actually runs the container that the install script built
on the colima machine.
```bash
restartdockerinstance
```

If you do this you should go directly into the shell.

I would also suggest adding these as aliases in your bashrc / zshrc.
```bash
export restartdockerinstance='<REPLACE_WITH_PATH_TO_RESTARTDOCKERINSTANCE_OR_COMMAND>'
export dockerbash='<REPLACE_WITH_PATH_TO_DOCKERBASH_OR_COMMAND>'
```

## Usage
Now that your environment is setup, you can simply ```dockerbash``` to get into your dev_instance. This will automatically take you into colima,
start the docker container, and attach to it (take you into the container on a shell).

From here you can access neovim using vi or vim, which should be like a full fledged editor.
See documentation on lazyvim.org and you can find keymaps on lazyvim.org/keymaps

You can use this to both edit code and run it, or simply edit it on your usual local dev environment (in the shared directory -- setup in 1b)
and run it in this dev_instance.



### Additional considerations
INSTALL A NERDFONT TO SEE NEOVIM ICONS CORRECTLY:
https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFontMono-Regular.ttf
Or firacode or SF Mono nerdfont (which I actually like better), you can find them online by searching up Fira Code NerdFont or SF Mono Nerd Font

After installation on most computers you can just click the .ttf file
Then, make sure you set your terminal's font to the nerdfont. (in settings).
