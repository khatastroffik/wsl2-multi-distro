# WSL2 multi distro

## Goal

The purpose of this repo is to propose a **step-by-step and script automating the creation and setup of multiple (linux) distributions** running in parallel under Windows 10 in **WSL2**.

**Prerequisite**: The windows 10 *WSL2 service* should be already installed and configured on your windows system. Setup and configuration of WSL/WSL2 is not part of this guide.

## Summary

A simplified distro instance creation scenario:

```text
#1: C:\WSL_INSTANCES\wsl.exe --import MYTESTDISTRO C:\WSL_INSTANCES\MYTESTDISTROFOLDER C:\WSL_DISTRO_REPOSITORY\ubuntu_18_04\install.tar.gz
#2: C:\WSL_INSTANCES\wsl.exe --distribution MYTESTDISTRO
#3: root@YOURHOSTPCNAME:/mnt/C/WSL_INSTANCES# ./initialize-distribution.sh
#4: root@YOURHOSTPCNAME:/mnt/C/WSL_INSTANCES# exit
#5: C:\WSL_INSTANCES\wsl.exe --terminate MYTESTDISTRO
```

**DONE!**

You may then (re-)start the created distro instance from any Windows 10 (PowerShell/Cmd/Terminal) terminal window and from within any directory. E.g.

```text
C:\Users\maestro>wsl.exe --distribution MYTESTDISTRO
```

## Detailled Step-By-Step 

### Prepare the distribution(s)

1. **Download** the distro package(s) you'd like to run in WSL2.

    Select/download the package(s) of your choice from the microsoft repository:
    
    https://docs.microsoft.com/en-us/windows/wsl/install-manual
    
    The distribution package should be saved once and re-used for multiple installation/instanciations.
    
    The following *distro repository* is used in this step-by-step: `D:\WSL\_repository\`.

1. **Unpack** the distribution package(s)
    
   The distro package should be unpacked to allow access to the contained `install.tar.gz` file. 
   
   The following structure is used for this step-by-step:
   
   ```text
   D:\WSL\_repository\ubuntu_18_04/                    # Folder containing an unpacked Distro
   D:\WSL\_repository\ubuntu_20_04/                    # Folder containing an unpacked Distro  
   D:\WSL\_repository\Ubuntu_1804.2019.522.0_x64.appx  # Distro File
   D:\WSL\_repository\Ubuntu_2004.2020.424.0_x64.appx  # Distro File   
   ```

1. **Integrate** (create) a *specific instance* of your distro into WSL

    For **each instance** of a distribution you'd like to run, you need to import the package installation file and register it, according to the following template:

    ```text
    D:\WSL\wsl.exe --import MYTESTDISTRO D:\WSL\MYTESTDISTROFOLDER D:\WSL\_repository\ubuntu_18_04\install.tar.gz
    ```
    
    where `MYTESTDISTRO` and `MYTESTDISTROFOLDER` should be replace as needed.
    
    Check if the import was successfull using:
    
    ```text
    D:\WSL\wsl.exe -l -v
    ```
    
    The Output should look like
    
    ```text
    D:\WSL\wsl.exe -l -v
      NAME                   STATE           VERSION
    * Ubuntu1804-001         Stopped         2
      Ubuntu1804-002         Stopped         2
      MYTESTDISTRO           Stopped         2         <- newly integrated distro
      web-server             Stopped         2
      web-backend            Stopped         2
      Odoo14                 Stopped         2
    ```
1. Download the **initialisation script**

    The script `initialize-distro.sh` should be downloaded from the git repository and saved in the WSL root repository to allow an easy access from the distro instance.
    
    When executed from within the distro, the script is automatically creating a **new sudoer user**, which should be used in place of the `root` user while accessing the distro instance terminals.
    
    Note: The **name of the created user** can be modified in the script directly.
    
#### Retrieve distribution packages from the windows apps store

You can retrieve distributions from the windows apps store i.e. use the package locally downloaded when installing a distro app from the windows apps store.

Windows apps store creates apps folders under `c:\program files\WindowsApps\`. You may need to grant your user READ rights on this folder in order to access its content.

Once you have located the correct distro folder (it should contain a `install.tar.gz` file), copy the content of the folder to your distro repository e.g. `D:\WSL\_repository\ubuntu_20_04/` and proceed with the **integrate** step as described above.

### Setup the distro instance

You need to setup and configure each instance of a distros you'd like to use, hence to repeat the following operations for each new/independent instance.

1. Start and **initialize** the new distribution instance

    Start the distribution instance using the following command:
    
    ```text
    D:\WSL\wsl.exe --distribution MYTESTDISTRO
    ```   

    Once the shell prompt of the distro instance is visible, run the initialization script (this make take a while to complete):
    
    ```shell
    root@YOURHOSTPCNAME:/mnt/d/WSL# ./initialize-distribution.sh
    ``` 
    
    This script will create a new user `sensei`, register it as a sudo user and update/upgrade the linux instance automatically. It will also configure the newly created user to be the **default WSL user** when (re-)starting the distro.
    
    You may be prompted to enter some user related information and password in order to complete the initialization procedure.

1. **Restart** the distro to apply the initialization
    
    After the setup procedure has been completed, you'd **exit the distro instance** using `exit` and **restart** it in order to apply all the configuration implemented by the initialization script:
    
    ```text
    root@YOURHOSTPCNAME:/mnt/d/WSL# exit
    
    D:\WSL\wsl.exe --terminate MYTESTDISTRO
    D:\WSL\wsl.exe --distribution MYTESTDISTRO
    ```
    
    or

    ```text
    D:\WSL\wsl.exe --shutdown
    D:\WSL\wsl.exe --distribution MYTESTDISTRO
    ```

    Note: when restarted, the distro instance should already use the newly created user. This should look like:
    
    ```shell
    ========================================
     MYTESTDISTRO - Ubuntu 20.04.2 LTS
    ========================================

    sensei@YOURHOSTPCNAME: ~$
    ```

### Optional

You'd probably like to configure the **appearance** of the **shell prompt** and **title**. The following is a suggestion for an adapted appearance and should be modified according to your need.

After the modification, both prompt and title should display as per `NAME-OF_THE_DISTRO_INSTANCE (USERNAME) CURRENT_FOLDER`.
   

To modifiy the appearance accordingly, some lines of code need to be modified in the user's own `.bashrc` file.

To load the file in an editor:

```shell
sensei@YOURHOSTPCNAME: ~$ sudo nano ~/.bashrc
```

Edit the content of this file as specified by the `# ***************** MODIFICATION *****************` comments in below code template (4 modifications in total):

```shell
...

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# ***************** MODIFICATION *****************
force_color_prompt=yes

# ***************** MODIFICATION *****************
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ [\1]/'
}

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    # ***************** MODIFICATION *****************
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;35m\]$WSL_DISTRO_NAME \[\033[01;32m\](\u)\[\e[91m\]$(parse_git_branch)\n\[\033[01;36m\]\w\[\033[00m\] \$ '
else
    # ***************** MODIFICATION *****************
    PS1='${debian_chroot:+($debian_chroot)}$WSL_DISTRO_NAME (\u)$(parse_git_branch)\n\w \$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    # ***************** MODIFICATION *****************
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}$WSL_DISTRO_NAME (\u)$(parse_git_branch)\n\w \a\]$PS1"
    ;;
*)
    ;;
esac
...
```

As before: to ensure the changes have been applied, you'd exit and restart the distro.
    
## Operate your distro instances
    
### Start to use a distro instance

```text
wsl --distribution MYTESTDISTRO
```

### Unregister a distro instance

```text
wsl --unregister MYTESTDISTRO
```

you may then delete the directory containing or safely backup the distro instance according to...

### Export/Backup a distro instance

From a windows *terminal window* (PowerShell/Cmd/Terminal), you can use the "WSL" CLI to export a (compressed) distro instance. This exported instance may then be reused as a source to create a new instance of the exported distro. It is also suitable for sharing prepared i.e pre-configured distro instances e.g. within a development team etc.

To export i.e. backup any distro instance, the template `wsl --export <NAME-OF-THE-DISTRO-INSTANCE> <PATH-TO-AND-NAME-OF-THE-BACKUP-TAR-FILE>` should be used. E.g.:

```text
wsl --export MYTESTDISTRO MYTESTDISTRO-BACKUP-001.tar
```

**Important**: WSL will *automatically terminate the instance if it is still running*! Hence, it is recommanded to close all connections to i.e. to **terminate the instance before exporting it**.

## License

This project is licensed under the terms of the MIT license.

## Ressources

- [use any Linux distribution inside of the Windows Subsystem for Linux (WSL) (Microsoft official documentation)](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro)
- [Guide to setting up WSL 2 with Multiple Identical Linux Distributions](https://www.hardtechnology.net/2020/09/19/wslcomplete.html)
- [How to Change / Set up bash custom prompt (PS1) in Linux](https://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html)
