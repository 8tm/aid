#!/usr/bin/env bash
# shellcheck disable=SC2001

DATE_TIME=$(date +"%Y-%m-%d_%H:%M:%S")                      # Date_Time constants i.e. 2021-11-19_22:24:26
MAIN_SOURCES_LIST_PATH="/etc/apt/sources.list"              # Set path to main sources list
                                                            # Get distribution codename
CODENAME=$(grep -F /debian/ < "${MAIN_SOURCES_LIST_PATH}" | grep -v "^ *#" | awk '{print $3}' | grep -v "[-/]"  | uniq)
USER_NAME=$(getent passwd 1000 |  awk -F: '{ print $1}')    # Get user name created while installing Debian
USER_SUDO_FILE_PATH="/etc/sudoers.d/${USER_NAME}"           # Path to user sudo file
FONT_COLOR_RED="\e[1;31;1m"                                 # Set font color to red
FONT_COLOR_GREEN="\e[1;32;1m"                               # Set font color to green
FONT_COLOR_OFF="\e[0m"                                      # Unset font color

message() {
    text="${1}"
    echo -e "${FONT_COLOR_GREEN}${text}${FONT_COLOR_OFF}"
}

run_as_root() {
    message "Backuping sources.list as ${MAIN_SOURCES_LIST_PATH}.backup.${DATE_TIME}"
    cp "${MAIN_SOURCES_LIST_PATH}" "${MAIN_SOURCES_LIST_PATH}.backup.${DATE_TIME}"  # Backup sources.list

    message "Enabling test repository"
    sed -i "s/${CODENAME}/testing/g" "${MAIN_SOURCES_LIST_PATH}"                    # Enable Test Repository

    # Check if sources.list was changed and contains Contrib and Non-free repositories
    message "Checking if contrib and non-free was added to sources.list"
    number_of_main_contrib_nonfree_entries=$(grep -c "main contrib non-free" < "${MAIN_SOURCES_LIST_PATH}")
    if [ "${number_of_main_contrib_nonfree_entries}" -gt 0 ]; then
        echo -e "${FONT_COLOR_RED}
        \r    main, contrib and non-free repositories found in \"${MAIN_SOURCES_LIST_PATH}\"
        \r    Please resolve this manualy!
        \r    Installation will continue, however sources.list file has not been changed for Contrib and Non-Free repositories!
        ${FONT_COLOR_OFF}"
    else
        message "Updated sources.list"
        sed -i "s/main/main contrib non-free/gI" "${MAIN_SOURCES_LIST_PATH}"     # Enabling Contrib and Non-free Repos
    fi

    message "Updating lists (apt update)"
    apt update                                                                   # Update lists

    message "Upgrading software (apt upgrade -yy)"
    apt upgrade -yy                                                              # Upgrade all packages

    message "Installing sudo (apt install -yy sudo)"
    apt install -yy sudo                                                         # Install base packages

    if [ ! -f "${USER_SUDO_FILE_PATH}" ]; then                                   # If user sudo file not exists
        message "Enabling sudo for user ${USER_NAME}"
        echo "${USER_NAME}  ALL=(ALL:ALL)  ALL" >> "${USER_SUDO_FILE_PATH}"      # Create sudo file for user
        chmod 0440 "${USER_SUDO_FILE_PATH}"                                      # Change chmod for file
    fi

    message "Finished root part."
    message "Please switch to user ${USER_NAME} and run this installer again."
}

run_as_user() {
    errors=()
    if [ ! -f "${USER_SUDO_FILE_PATH}" ]; then
        errors+=("\n${FONT_COLOR_RED}\n----You-need-SUDO-permissions-to-continue.\n----Please-run-this-script-as-root-to-install-sudo-for-your-user-${USER}\n${FONT_COLOR_OFF}")
    fi

    if [ -z "${GITHUB_ACCESS_TOKEN}" ]; then
        errors+=("${FONT_COLOR_RED}\n----Please-set-your-access-token-to-constant-GITHUB_ACCESS_TOKEN.\n----example:-export-GITHUB_ACCESS_TOKEN=\"ghp_1ab2CdEfGhijklmNopQ3RStuvWxYZA4bcD5F\"\n${FONT_COLOR_OFF}")
    fi

    if [ -z "${GITHUB_INSTALLER_URL}" ]; then
        errors+=("${FONT_COLOR_RED}\n----Please-set-variable-GITHUB_INSTALLER_URL-pointing-to-installer-repository-by-https-protocol.\n----example:-export-GITHUB_INSTALLER_URL=https://github.com/user_name/repositoru_name.git\n${FONT_COLOR_OFF}")
    fi

    if [ ${#errors[@]} -gt 0 ]; then
        echo -e "\n    Found errors:"
        for error in "${errors[@]}";
        do
            echo -e "${error//-/ }"
        done
        echo -e "
        \r    Please fix errors and run this installer again!
        \r    Terminating
        "
        return 13
    fi

    TOKENIZED_GITHUB_URL=$(echo "${GITHUB_INSTALLER_URL}" | sed -e "s#https://#https://${GITHUB_ACCESS_TOKEN}@#g")

    # Operations
    message "Updating lists (sudo apt update)"
    sudo apt update                                       # Update lists

    message "Upgrading software (sudo apt upgrade -yy)"
    sudo apt upgrade -yy                                  # Upgrade all packages

    message "Installing GIT (sudo apt install -yy git)"
    sudo apt install -yy git                              # Install base packages

    message "Cloning repository ${GITHUB_INSTALLER_URL}"
    git clone "${TOKENIZED_GITHUB_URL}"                   # Clone your repository using Access Token

    # Get folder name from github installer url
    repository_folder_name=$(                      \
        echo "${GITHUB_INSTALLER_URL}"           | \
        awk 'BEGIN {FS="github.com/"}{print $2}' | \
        awk 'BEGIN {FS="/"}{print $NF}'          | \
        sed -e 's/.git//g'                         \
    )
    # Go to cloned repository
    message "Changing directory to $(pwd)/${repository_folder_name}"
    cd "${repository_folder_name}" || echo "Repository not exists or something strange happen"

    # Run installer with rest of commands
    message "Running after installer for Debian (./after_installer_for_debian.sh)"
    ./after_installer_for_debian.sh
    message "Finished user part."
}


if [[ $EUID -eq 0 ]]; then
    run_as_root
else
    run_as_user
fi
