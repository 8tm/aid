# After Installer for Debian O.S.

### What is this anyway?

This is a simple script designed to help me install Debian packages after standard installation and as soon as possible.
It's first of two required repositories to install all packages etc.
This repository contains only main installation script.
Other files I'll add to my private repository and after all I'll create some template for all. 


It's task is quite simple:

Do the simplest things on the root account:
- Backup sources.list file (filename format: sources.list.backup.2021-11-20_02:23:48)
- Enable Debian testing repository (instead stable one)
- Add contrib and non-free repositories to sources.list
- Update lists
- Upgrade installed packages
- Install sudo package
- Create sudoers file for user created during installation process

After that I can switch to my user account and script will do next things:
- Check if sudo file for my user exists
- Check if exists both constants in shell (GITHUB_INSTALLER_URL and GITHUB_ACCESS_TOKEN)
- Update lists
- Upgrade packages
- Install git package
- Clone git private repository using both of constants (GITHUB_*)
- Run the `after_installer_for_debian.sh` script located in the cloned repository to execute next commands


### Installation

Login as root and run command:
```shell
wget -O - tinyurl.com/afterinstaller | bash
```
After a while logout and login as a user which you created while installing Debian and create constants:

GITHUB_INSTALLER_URL - Url to repository with file `after_installer_for_debian.sh` and anything else you want (It can be public or private repository)
```shell
# example:
export GITHUB_INSTALLER_URL=https://github.com/yourusername/repository_with_your_installer
```

GITHUB_ACCESS_TOKEN - Token created for your user in https://github.com
```shell
# example:
export GITHUB_ACCESS_TOKEN=ghp_1ab2CdEfGhijklmNopQ3RStuvWxYZA4bcD5F
```

Next run command:
```shell
wget -O - tinyurl.com/afterinstaller | bash
```


### You can do the same manually

Well... Yes, but No.

Manually solution will:
- Took more time
- Cost me more nerves if I forget some of packages
- It does not allow the installation to be repeated in the same way

Using simple script I can:
- Use dialog to create CUI interface
- Select all or only part of software I need
- Copy configuration files from the repository instead of reconfiguring the installed default files
- Create my own "recipes" for everything I need (software, configurations, any commands executed manually)
- Create folder structure for all files, folders
- Mount disks which wasn't connected during linux installation
- Install additional backgrounds, fonts other files
- Anything else I need (download repositories, install software from sources etc)


This project has not been completed yet. If you can see this information, it probably means I haven't finished the template in the second repository yet.
