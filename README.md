# Bootstrap-AI-DevBox

Easily Bootstrap an AI/Data Science/Deep Learning DevBox for Ubuntu Desktop 18.04 LTS

## Overview

The goal of this project it to provide some useful scripts to quickly and easily bootstrap an AI/Data Science/Deep Learning environment on top of a fresh Ubuntu 18.04 LTS installation.

The motivation behind this project:
- Upgrade my AI DevBox and DataScience VMs from Ubuntu 16.04 LTS (EOL) to **Ubuntu 18.04 LTS**
- Almost **Zero Configuration**: Automate as much as possible the whole process
- **Make the process repeatable, easy to maintain**, usable (almost?) anywhere and customizable
- Pre-install some popular **Data Scientists tools to be ready to use**
- **Avoid some painful Ubuntu installations steps** (Proxy setup, **Nvidia GPU Drivers** installation, replace the poor Ubuntu 18.04 Window Manager GUI by the **Unity Window Manager**, automate (my favorite) settings configuration, optionally restore previous user's configuration files and program extensions...)

Remark: This project is not intended to setup production environment, or clusters in the cloud, ... It's main purpose is to setup a workstation or a local VM. As such, in order to keep the things simple and the configuration minimal, it has been chosen to bundle all the Ansible installation in a single yaml file instead of following Ansible playbook organization best practices.


![Docker-AI](/images/ubuntu18-unity.png)


## Usage

### Prerequisites

1. Have a fresh Ubuntu Desktop 18.04 LTS 'Bionics' installation (either on bare metal or in a Virtual Box VM). No prior update or any further configuration needed:
   - Link to download the [Ubuntu Desktop 18.04 iso file](https://ubuntu.com/download/desktop)
   - Useful tool to flash the OS image on an USB Key : [Etcher](https://www.balena.io/etcher/)
   - Link to download [VirtualBox ](https://www.virtualbox.org/)

For VirtualBox setup, I suggest the following settings:
   - At least 3 cores, 12GB of RAM, 48MB for Video Memory (YMMV)
   - In case the Ubuntu 18 installation would "freeze" (gray display) at some point during the installation, just select "Pause" in the Virtual Box Window menu to pursue the installation.
   - Create a VDI, Dynamically Allocated Hard Drive of 30GB, with 4096MB of Swap and the rest for an ext4 partition (FYI, after the installation is completed, and without any GPU installation, the size used by the VDI file is roughly 14 GB)
   - Add an Optical Drive for "VBoxGuestAdditions.iso" (the installer will look for it to automatically install it if available)

2. Copy/clone the project in your user's home directory:

     - `~/Bootstrap-AI-DevBox/install-ansible.sh` (make sure it is executable, try `chmod u+x` if needed)
     - `~/Bootstrap-AI-DevBox/Install-DevBox.yaml`
     - `~/Bootstrap-AI-DevBox/PrivateConfiguration.tar.gz` (Optional) - You may manually provide your backup configuration files (like `.bashrc`, `.git`, pictures...) and directories (`.vscode`, `.config/sublime-text-3`, ...) that will be restored in `~/`
     - `~/Bootstrap-AI-DevBox/fonts.tar.gz` (Optional) - You may manually provide an archive containing ttf fonts to installed.

3. If you are behind a Proxy:

    Edit the `~/Setup/install-ansible.sh` file and enter the appropriate values for the proxy settings. See:

    ```
    export PROXY_HOST="proxy.acme.com"
    export PROXY_PORT="1234"

    ```

    This script will propagate the proxy settings to the Ansible playbook automatically. If you wish to use manually the Ansible playbook `~/Setup/Install-DevBox.yaml`, then either pass the required environment variables to the Ansible playbook :

    `ansible-playbook -K -e "logname=$(logname)" -e "proxyhost=<PROXY_HOST>" -e "proxyport=<PROXY_PORT>" Install-DevBox.yaml`

    or specify the default values in the yaml playbook file:
    ```
    vars:
      user: "{{ logname | default('<DEFAULT_USER_LOGIN>') }}"          # Default user login name to configure
      proxy_host: "{{ proxyhost | default('<DEFAULT_PROXY_HOST>') }}"  # Leave empty ('') default value for no proxy
      proxy_port: "{{ proxyport | default('<DEFAULT_PROXY_PORT>') }}"  # Leave empty ('') default value for no proxy
    ```


### Quickstart

Just execute the installation script:

```
# Clone this project in your Ubuntu Home directory

cd ~/Bootstrap-AI-DevBox
chmod u+x *.sh
sudo -E ./install-ansible.sh
```

### Backup/Restore your user's account configuration
- If you want to backup your user's configuration (bash, git, xorg.conf, Nvidia NGC token, Sublime Text (settings, plug-ins and license), Visual Studio Code, PyCharm, Wallpapers pictures), just execute the script `~/Bootstrap-AI-DevBox/backup-config.sh`. This script will create an archive ` ~/Bootstrap-AI-DevBox/PrivateConfiguration.tar.gz`.

- Just put back that archive in `~/Bootstrap-AI-DevBox/PrivateConfiguration.tar.gz` before bootstrapping an environment in order to have the Ansible Playbook to automatically restore these configuration files.

Cuurently, the backup covers the following content:

```
.gitconfig
.git-credentials
.profile
.bashrc
.ngc/config
.docker/config.json
.config/conky/
/etc/X11/xorg.conf
.config/sublime-text-3/Installed Packages
.config/sublime-text-3/Packages/
.config/sublime-text-3/Local/License.sublime_license
.vscode/
.config/Code/User/
.local/share/applications/jetbrains-pycharm.desktop
.local/share/JetBrains/
.PyCharm2019.3/config/
.PyCharm2019.3/system
.java/userPrefs/
/usr/local/bin/charm
Pictures/
```

## Setup Content

The `install-ansible.sh` shell script will:

- setup the proxy for apt (if needed)
- install Python3 minimal (for ansible)
- install Ansible from the ppa:ansible/ansible repository
- execute the `Install-DevBox.yaml` Ansible playbook


The `Install-DevBox.yaml` playbook will:

- Check that a user login name is provided to ensure the correct Playbook execution
- setup the proxy for apt, ubuntu (if needed)
- restore some previous user's configuration if provided (optional)
- disable the screensaver
- update/upgrade the Ubuntu distribution
- install [**python 3**](https://docs.python.org/3.6/index.html)
- install [**conda**](https://docs.conda.io/projects/conda/en/latest/)
   - **IMPORTANT**:  the installtion is also patching conda to avoid "Maximum Recursion Errors"
- if available, install the `VBoxGuestAdditions.iso` software (optional, VBox only)
- install a firewall and enable SSH connection
- install useful softwares (shell tools, Nemo file manager, Chromium browser, generic development tools)
- install [**Sublime Text 3**](https://www.sublimetext.com/3) (installation can be disable with an Ansible variable)
  - I recommend to install the following [Package Control](https://packagecontrol.io/installation) extensions : Pretty YAML, Pretty JSON, SideBarEnhancements, Trimmer, Unicode Character Highlighter, Print to HTML, Dockerfile Syntax Highlighting, Clickable URLs
- install [**Visual Studio Code**](https://code.visualstudio.com/) (installation can be disable with an Ansible variable)
  - I recommend to install the following extensions: Python (from Mirosoft), YAML (from Red Hat), JSON (by ZainChen), XML (by Red Hat), Docker (by Microsoft), Kubernetes (By Microsoft)
- install [**PyCharm Pro**](https://www.jetbrains.com/pycharm/) (installation can be disable with an Ansible variable. Pycharm version to download is defined in an Ansible variable)
- install **Unity window manager** (+ settings configuration tools) and define it as the default window manager
- uninstall Ubuntu 18.04 Gnome Window Manager
- customize some GUI settings and shortcuts
- uninstall unnecessary apps (games, Amazon, (duplicate and slow) Gnome Snap version of some apps, ...)
- install [**Nvidia Drivers and CUDA**](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html) from Nvidia official repository  (optional and automatic if a Nvidia PCIe GPU device is detected):
   - This also make sure to remove "graphics-drivers/ppa" repository or "Nouveau" drivers.
   - Note that the installation need to overwrite an Ubuntu 18.04 file
- install and [**setup Docker CE**](https://docs.docker.com/install/linux/docker-ce/ubuntu/) (Automatic start, proxy if needed)
- install [**Nvidia Docker 2**](https://github.com/NVIDIA/nvidia-docker) (optional and automatic if a Nvidia PCIe GPU device is detected)
- install Nvidia NGC CLI
- clean the installation (remove unused packages, logs, temp files, repair file permissions...)
- reboot

## Limitations / Known Issue:

- As Jetbrains does not provide a Deb package to install PyCharm on Ubuntu, a tarball archive is used. As a consequence, Pycharm will not automatically be updated with `apt-get upgrade` and will have to be updated manually.

- Possible Bluetooth compatibility issue with Ubuntu 18.04 LTS:

  - As of February 2020, I met some issues to stream audio from an with Ubuntu 18.04 LTS to an Amazon Echo device, using a "No Name" Blueetooth usb key with a Broadcom BCM920702 Bluetooth 4.0 chip. Ubuntu 16.04.LTS, with latest updates, did not met any issue to connect to the Echo's Audio input and ouput. I changed the Bluetooth USB key model to a TP-Link UB400 : This time the Echo device is seen as an output (Streaming audio to the Echo device is now OK), but no more as an input...

## Add-ons

You may be interested in my [Docker-AI](https://github.com/fdasilva59/Docker-AI) project which allows to easily build a customizable, ready to use Docker Image for some AI/Data Science/Deep Learning experiments.

## License

MIT

Wallpaper used in my Docker-AI installation screen-shot: Copyright by [HonooNoKarite](https://www.deviantart.com/honoonokarite/art/Wallpaper-Ubuntu-Widescreen-167876024)
