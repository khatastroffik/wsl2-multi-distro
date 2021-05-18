# WSL2 multi distro

## Goal

The purpose of this repo is to propose a **step-by-step and script automating the creation and setup of multiple (linux) distributions** running in parallel under Windows 10 in **WSL2**.

**Prerequisite**: The windows 10 *WSL2 service* should be already installed and configured on your windows system. Setup and configuration of WSL/WSL2 is not part of this guide.

## Summary

A simplified distro instance creation scenario:

```
#1: C:\WSL_INSTANCES\wsl.exe --import MYTESTDISTRO C:\WSL_INSTANCES\MYTESTDISTROFOLDER C:\WSL_DISTRO_REPOSITORY\ubuntu_18_04\install.tar.gz
#2: C:\WSL_INSTANCES\wsl.exe --distribution MYTESTDISTRO
#3: root@YOURHOSTPCNAME:/mnt/C/WSL_INSTANCES# ./initialize-distribution.sh
#4: root@YOURHOSTPCNAME:/mnt/C/WSL_INSTANCES# exit
#5: C:\WSL_INSTANCES\wsl.exe --terminate MYTESTDISTRO
```

**DONE!**

You may then (re-)start the created distro instance from any Windows 10 (PowerShell/Cmd/Terminal) terminal window and from within any directory. E.g.

```
C:\wsl.exe --distribution MYTESTDISTRO
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
   
   ```
   D:\WSL\_repository\ubuntu_18_04/                    # Folder containing an unpacked Distro
   D:\WSL\_repository\ubuntu_20_04/                    # Folder containing an unpacked Distro  
   D:\WSL\_repository\Ubuntu_1804.2019.522.0_x64.appx  # Distro File
   D:\WSL\_repository\Ubuntu_2004.2020.424.0_x64.appx  # Distro File   
   ```

1. **Integrate** (create) a *specific instance* of your distro into WSL

    For **each instance** of a distribution you'd like to run, you need to import the package installation file and register it, according to the following template:

    ```cmd
    wsl --import MYTESTDISTRO D:\WSL\MYTESTDISTROFOLDER D:\WSL\_repository\ubuntu_18_04\install.tar.gz
    ```
    
    where `MYTESTDISTRO` and `MYTESTDISTROFOLDER` should be replace as needed.
    
    Check if the import was successfull using:
    
    ```cmd
    wsl -l -v
    ```
    
    The Output should look like
    
    ```    
    D:\WSL\wsl -l -v
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
    
### Setup the distro instance

You need to setup and configure each instance of a distros you'd like to use, hence to repeat the following operations for each new/independent instance.

1. Start and **initialize** the new distribution instance

    Start the distribution instance using the following command:
    
    ```cmd
    wsl --distribution MYTESTDISTRO
    ```   

    Once the shell prompt of the distro instance is visible, run the initialization script (this make take a while to complete):
    
    ```bash
    root@YOURHOSTPCNAME:/mnt/d/WSL# ./initialize-distribution.sh
    ``` 
    
    This script will create a new user `sensei`, register it as a sudo user and update/upgrade the linux instance automatically. It will also configure the newly created user to be the **default WSL user** when (re-)starting the distro.
    
    You may be prompted to enter some user related information and password in order to complete the initialization procedure.

1. **Restart** the distro to apply the initialization
    
    After the setup procedure has been completed, you'd **exit the distro instance** using `exit` and **restart** it in order to apply all the configuration implemented by the initialization script:
    
    ```cmd
    root@YOURHOSTPCNAME:/mnt/d/WSL# exit
    
    D:\WSL\wsl --terminate MYTESTDISTRO
    D:\WSL\wsl --distribution MYTESTDISTRO
    ```
    
    or

    ```cmd
    wsl --shutdown
    wsl --distribution MYTESTDISTRO
    ```

    Note: when restarted, the distro instance should already use the newly created user. This should look like:
    
    ```bash
    ========================================
     MYTESTDISTRO - Ubuntu 20.04.2 LTS
    ========================================

    Starting the postgreSQL service...
    [sudo] password for sensei:
     * Starting PostgreSQL 12 database server                                                                                                                                         [ OK ] testdistro(sensei) ~$    
    sensei@YOURHOSTPCNAME: ~$
    ```

### Optional

You'd probably like to configure the **appearance** of the **shell prompt** and **title**. The following is a suggestion for an adapted appearance and should be modified according to your need.

After the modification, both prompt and title should display as per `NAME-OF_THE_DISTRO_INSTANCE (USERNAME) CURRENT_FOLDER`.
   

To modifiy the appearance accordingly, some lines of code need to be modified in the user's own `.bashrc` file.

To load the file in an editor:

```bash
sensei@YOURHOSTPCNAME: ~$ sudo nano ~/.bashrc
```

Edit the content of this file as specified by the `# ***************** MODIFICATION *****************` comments in below code template (4 modifications in total):

```bash
...

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# ***************** MODIFICATION *****************
force_color_prompt=yes

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
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;35m\]$WSL_DISTRO_NAME\[\033[00m\](\[\033[01;32m\]\u\[\033[00m\]) \[\033[01;36m\]\w\[\033[00m\]\$ '
else
    # ***************** MODIFICATION *****************
    PS1='${debian_chroot:+($debian_chroot)}$WSL_DISTRO_NAME(\u) \w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    # ***************** MODIFICATION *****************
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}$WSL_DISTRO_NAME (\u) \w\a\]$PS1"
    ;;
*)
    ;;
esac

...
```

As before: to ensure the changes have been applied, you'd exit and restart the distro.
    
## Operate your distro instances
    
### Start to use a distro instance

```cmd
wsl --distribution MYTESTDISTRO
```

### Unregister a distro instance

```cmd
wsl --unregister MYTESTDISTRO
```

you may then delete the directory containing or safely backup the distro instance according to...

### Export/Backup a distro instance

From a windows *terminal window* (PowerShell/Cmd/Terminal), you can use the "WSL" CLI to export a (compressed) distro instance. This exported instance may then be reused as a source to create a new instance of the exported distro. It is also suitable for sharing prepared i.e pre-configured distro instances e.g. within a development team etc.

To export i.e. backup any distro instance, the template `wsl --export <NAME-OF_THE_DISTRO_INSTANCE> <NAME-OF_THE-BACKUP-TAR-FILE>` should be used. E.g.:

```bash
MYTESTDISTRO(sensei) ~$ wsl --export MYTESTDISTRO D:\WSL\MYTESTDISTRO-BACKUP-001.tar
```

Note: WSL wil *automatically terminate the instance if it is running*. Hence, it is recommanded to close all connections to i.e. to **terminate the instance before exporting it**.

## Ressources

https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro

https://www.hardtechnology.net/2020/09/19/wslcomplete.html

https://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html
