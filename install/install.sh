#! /bin/bash
# vim:fileencoding=utf-8:foldmethod=marker

# Check if root
if [ "$EUID" -ne 0 ]
then
    printf -- 'Please run as root\n'
    exit
fi

PARENT_COMMAND=$(ps -o comm= $PPID)
ROOT_DIR=${PWD##*/}
if [[ $ROOT_DIR != "dotfiles" ]] || [[ $PARENT_COMMAND != "setup_arch.sh" ]]
then
    printf -- 'Please run arch install script with setup_arch.sh\n'
    exit
fi

# Variables {{{

COLOR_RESET="\e[0m"
TEXT_BOLD="\e[1m"
COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_BLUE="\e[34m"
COLOR_LIGHT_BLUE="\e[94m"

# }}}

# Helper functions {{{

# if CTRL+C is pressed twice in a second, terminate script
last=0
function allow_quit() {
    [ $(date +%s) -lt $(( $last + 1 )) ] && exit
    last=$(date +%s)
}
trap allow_quit 2

function check_return_code() {
    if [[ $? == 0 ]]
    then
        printf -- "${TEXT_BOLD}${COLOR_GREEN}%s${COLOR_RESET}\n" 'Done'
    else
        printf -- "${TEXT_BOLD}${COLOR_RED}%s${COLOR_RESET}\n" 'Failed'
        printf -- 'Exiting...'
        exit 1
    fi
}
function print_banner() {
    local delimiter='='
    local line="$1"
    local columns=49

    # set color
    # printf -- "${TEXT_BOLD}${COLOR_LIGHT_BLUE}"

    # top delimiter
    printf -- "${delimiter}%.0s" {1..50}
    printf -- "\n"

    # center stage
    printf -- "|"
    # print centered word
    printf "%*s" $(( (${#line} + columns) / 2 )) "$line"
    # print right pipe
    printf "%*s\n" $(( columns - (${#line} + columns) / 2 )) "|"

    # bottom delimiter
    printf -- "${delimiter}%.0s" {1..50}
    printf -- "\n"

    # reset color to normal
    # printf -- "${COLOR_RESET}"
}
function print_stage_banner() {
    printf -- "${TEXT_BOLD}${COLOR_LIGHT_BLUE}"
    print_banner "$1"
    printf -- "${COLOR_RESET}"
}
function print_stage() {
    printf -- "\t$1. $2\n"
}

# }}}

# Get device type
printf -- "${COLOR_LIGHT_BLUE}:: Which device are you on? ${COLOR_RESET}[normal/rpi0/${COLOR_GREEN}RPI4${COLOR_RESET}]${COLOR_LIGHT_BLUE}: ${COLOR_RESET}"
read device
device=$(printf -- "$device" | tr '[:upper:]' '[:lower:]')
device=${device:-rpi4}

printf -- '\n'

# TODO: check if proper device was selected
# TODO: install veracrypt

# Get name of new user {{{
printf -- "${COLOR_LIGHT_BLUE}:: What user do you want to create? ${COLOR_RESET}(${COLOR_GREEN}pipo${COLOR_RESET})${COLOR_LIGHT_BLUE}: ${COLOR_RESET}"
read user_name
# strip spaces from name
user_name=$(printf -- "$user_name" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
user_name=${user_name:-pipo}

printf -- '\n'
# }}}

# Ask to shorten boot time only if on RPI device
if [[ $device == rpi* ]]
then
	# ask if to shorten boot time
    while true; do
        printf -- "${COLOR_LIGHT_BLUE}:: Do you want to shorten boot time by disabling services that are not needed? ${COLOR_RESET}(${COLOR_GREEN}Y${COLOR_RESET}/n${COLOR_RESET})${COLOR_LIGHT_BLUE}: ${COLOR_RESET}"
        read yn
	    yn=${yn:-y}

        case $yn in
            [Yy]* ) yn="y"; break;;
            [Nn]* ) yn="n"; break;;
            * ) printf -- "${COLOR_RED}invalid${COLOR_RESET}\n";;
        esac
    done

	shorten_boot=$yn

	printf -- '\n'
fi

# Ask if to overclock rpi to 1750Mhz if rpi4
if [[ $device == rpi4 ]]
then
	# ask if to overclock rpi 4 to 1750Mhz
    while true; do
        printf -- "${COLOR_LIGHT_BLUE}:: Do you want to overclock rpi 4 to 1750Mhz? ${COLOR_RESET}(${COLOR_GREEN}Y${COLOR_RESET}/n${COLOR_RESET})${COLOR_LIGHT_BLUE}: ${COLOR_RESET}"
        read yn
	    yn=${yn:-y}

        case $yn in
            [Yy]* ) yn="y"; break;;
            [Nn]* ) yn="n"; break;;
            * ) printf -- "${COLOR_RED}invalid${COLOR_RESET}\n";;
        esac
    done

	overclock_rpi=$yn

	printf -- '\n'
fi

# Ask if to install Samba server
if [[ $device == rpi* ]]
then
    # ask if to install samba server
    while true; do
        printf -- "${COLOR_LIGHT_BLUE}:: Do you want to install Samba server? ${COLOR_RESET}(${COLOR_GREEN}Y${COLOR_RESET}/n${COLOR_RESET})${COLOR_LIGHT_BLUE}: ${COLOR_RESET}"
        read yn
	    yn=${yn:-y}

        case $yn in
            [Yy]* ) yn="y"; break;;
            [Nn]* ) yn="n"; break;;
            * ) printf -- "${COLOR_RED}invalid${COLOR_RESET}\n";;
        esac
    done

	samba_install=$yn
	
	printf -- '\n'
fi

# Ask if to install KODI
if [[ $device == rpi* ]]
then
    while true; do
        printf -- "${COLOR_LIGHT_BLUE}:: Do you want to install KODI? ${COLOR_RESET}(${COLOR_GREEN}Y${COLOR_RESET}/n${COLOR_RESET})${COLOR_LIGHT_BLUE}: ${COLOR_RESET}"
        read yn
	    yn=${yn:-y}

        case $yn in
            [Yy]* ) yn="y"; break;;
            [Nn]* ) yn="n"; break;;
            * ) printf -- "${COLOR_RED}invalid${COLOR_RESET}\n";;
        esac
    done

	kodi_install=$yn

	printf -- '\n'
fi

# Ask if to setup aria2 with ariaNg
if [[ $device == rpi* ]]
then
    while true; do
        printf -- "${COLOR_LIGHT_BLUE}:: Do you want to setup aria2 with ariaNg? ${COLOR_RESET}(${COLOR_GREEN}Y${COLOR_RESET}/n${COLOR_RESET})${COLOR_LIGHT_BLUE}: ${COLOR_RESET}"
        read yn
	    yn=${yn:-y}

        case $yn in
            [Yy]* ) yn="y"; break;;
            [Nn]* ) yn="n"; break;;
            * ) printf -- "${COLOR_RED}invalid${COLOR_RESET}\n";;
        esac
    done

	ariaNg_setup=$yn

	printf -- '\n'
fi

# Ask if to setup automnt
while true; do
    printf -- "${COLOR_LIGHT_BLUE}:: Do you want to setup auto mount? ${COLOR_RESET}(${COLOR_GREEN}Y${COLOR_RESET}/n${COLOR_RESET})${COLOR_LIGHT_BLUE}: ${COLOR_RESET}"
    read yn
    yn=${yn:-y}

    case $yn in
        [Yy]* ) yn="y"; break;;
        [Nn]* ) yn="n"; break;;
        * ) printf -- "${COLOR_RED}invalid${COLOR_RESET}\n";;
    esac
done
auto_mount=$yn
printf -- '\n'

# Create new user $user_name instead of the default one {{{
function create_new_user() {
    print_stage_banner "create_new_user()"

    printf -- 'Checking if user exists...\n'
    # check if user exists
    if ! id "$user_name" &> /dev/null
    then
        # user was not found
        printf -- 'User %s not found. Creating user...' "$user_name"

        # add user
        useradd "$user_name" -G wheel,sys -m
        check_return_code

        # asks for password till both are same
        while true; do
            read -p "Insert password for user $user_name: " -s password
            echo
            read -p "Insert password again: " -s password_check
            echo

            # if password are same, then break loop
            [ "$password" == "$password_check" ] && break
            printf -- 'Please try again\n'
        done

        printf -- 'Changing password...'
        echo $user_name:$password | chpasswd
        check_return_code
    else
        printf -- "User %s was found..." "$user_name"
        check_return_code
    fi

    printf -- '\n'
}
# }}}

# Configure users dotfiles {{{
function configure_user() {
    print_stage_banner "configure_user()"

    printf -- "Copying dotfiles to '$user_name' folder..."
    cp .profile .bashrc .bash_profile /home/$user_name
    check_return_code

    printf -- '\n'
}
# }}}

# Configure locale {{{
function configure_locale() {
    print_stage_banner "configure_locale()"

    printf -- 'Updating /etc/locale.gen file...'
    # in file /etc/locale.gen find line '#en_US.UTF-8 UTF-8' and uncomment with sed
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    check_return_code

    printf -- 'Generating locale...'
    locale-gen
    check_return_code

    printf -- '\n'
}
# }}}

# Configure time zone {{{
function configure_time_zone() {
    print_stage_banner "configure_time_zone()"

    printf -- 'Configuring time zone...'
    timedatectl set-timezone Europe/Bratislava
    check_return_code

    printf -- '\n'
}
# }}}

# Make pacman colorful {{{
function configure_colorful_pacman() {
    print_stage_banner "configure_colorful_pacman()"

    printf -- 'Setting colorful pacman...'
    #  uncomment '#Color' in /etc/pacman.conf
    sed -i 's/^#Color/Color/' /etc/pacman.conf
    check_return_code

    printf -- '\n'
}
# }}}

# Add pipo to sudoers file {{{
function configure_sudoers() {
    print_stage_banner "configure_sudoers()"

    # if env keep exists, dont add it
    if ! grep -qxF 'Defaults env_keep += "EDITOR VISUAL"' /etc/sudoers
    then
        printf -- 'Adding env_keep EDITOR and VISUAL...'
        sed -i '1s/^/Defaults env_keep += "EDITOR VISUAL"\n/' /etc/sudoers
    else
        printf -- 'Already exists env_keep EDITOR and VISUAL...'
    fi
    check_return_code

    # if wheel is in sudoers, dont add it
    if ! grep -qxF '%wheel ALL=(ALL) ALL' /etc/sudoers
    then
        printf -- 'Adding group %wheel to sudoers...'
        sed -i '1s/^/%wheel ALL=(ALL) ALL\n/' /etc/sudoers
    else
        printf -- 'Already exists group %%wheel in sudoers...'
    fi
    check_return_code

    printf -- '\n'
}
# }}}

# Configure boot {{{
function configure_boot() {
    if [[ "$device" -eq "rpi" ]]
    then
        print_stage_banner "configure_boot()"

        # TODO: somehow differentiate between arch64 and 32 to properly setup boot
        # TODO: arch 64 uses uboot
        # TODO:     need to install uboot-tools
        # TODO:     edit /boot/boot.txt arguments
        # TODO:     then compile it with ./mkscr

        # TODO: https://archlinuxarm.org/forum/viewtopic.php?f=65&t=13388
        # printf -- "Editing '/boot/cmdline.txt'..."
        # # find line that doesnt start with #
        # # that contains root=/dev/
        # # and that doenst already have random.trust_cpu
        # # and if so than append random.trust_cpu=on to /boot/cmdline.txt
        # sed -i '/^[^#]*root=\/dev\// {/random.trust_cpu/!  s/$/ random.trust_cpu=on/}' /boot/cmdline.txt
        # check_return_code

        printf -- "Copying boot config..."
        # copy boot config into /boot
        cp install/config/boot/config.txt /boot
        check_return_code

        if [[ $overclock_rpi == "y" ]]
        then
            printf -- "Overclocking rpi 4 to 1750Mhz..."
            sed -i '/^#over_voltage/ s/^#//' /boot/config.txt
            sed -i '/^#arm_freq/ s/^#//' /boot/config.txt
            check_return_code
        fi

        printf -- '\n'
    fi
}
# }}}

# Install sudo {{{
function install_sudo() {
    print_stage_banner "install_sudo()"

    printf -- 'Installing sudo...'
    pacman -S --needed sudo
    check_return_code

    printf -- '\n'
}
# }}}

# install yay {{{
function install_yay() {
    print_stage_banner "install_yay()"

    if command -v yay &> /dev/null
    then
        printf -- 'Yay already installed...'
        check_return_code
        return 0
    fi

    printf -- 'Updating pacman cache...\n'
    pacman -Syy
    check_return_code

    printf -- 'Installing dependencies "git base-devel"...\n'
    pacman -S --needed git base-devel
    check_return_code

    local home_dir=/home/$user_name

    printf -- 'Creating users ~/Documents ~/Downloads folders...'
    sudo -u $user_name mkdir -p $home_dir/Documents $home_dir/Downloads
    check_return_code

    local yay_dir=$home_dir/Downloads/yay
    # check if ~/Downloads/yay exists
    if [[ -d $yay_dir ]]
    then
        printf -- 'Yay dir exists... Making backup...'
        mv $yay_dir ${yay_dir}-backup
        check_return_code
    fi

    printf -- 'Getting yay from git...\n'
    local curr_dir=$(pwd)

    printf -- "Downloading yay into $home_dir/Downloads..."
    cd $home_dir/Downloads && sudo -u $user_name git clone "https://aur.archlinux.org/yay.git"
    check_return_code

    printf -- 'Installing yay...\n'
    cd $home_dir/Downloads/yay && sudo -u $user_name makepkg -si
    check_return_code
    
    cd $curr_dir

    printf -- '\n'
}
# }}}

# install other packages {{{
function install_packages() {
    print_stage_banner "install_packages()"

    printf -- 'Installing other packages...'
    sudo -u $user_name yay -S lsd neofetch htop figlet exfat-utils udisks2 screen ntfs-3g openssh p7zip wget
    check_return_code

    if [[ $device == rpi* ]] && [[ $device != rpi0 ]]
    then
        printf -- 'Installing zsh...'
        sudo -u $user_name yay -S zsh prezto-git
        check_return_code

        printf -- "Copying zsh configs into '$user_name' folder..."
        cp -r .zshrc .zpreztorc .p10k.zsh .zsh/ /home/$user_name
        check_return_code
    fi

    if [[ $device == rpi* ]]
    then
    	printf -- 'Installing rng-tools, ufw on RPi...'
    	sudo -u $user_name yay -S rng-tools ufw avahi
        check_return_code
    fi
    
    if [[ $device == "rpi4"  ]] || [[ $device == "normal" ]]
    then
        printf -- 'Installing ffmpeg, youtube-dl...'
        sudo -u $user_name yay -S ffmpeg youtube-dl
        check_return_code
    fi

    if [[ $ariaNg_setup == "y" ]]
    then
        printf -- 'Installing aria2, nginx...'
        sudo -u $user_name yay -S aria2 nginx
        check_return_code

        local home_dir=/home/$user_name
        local curr_dir=$(pwd)

        printf -- 'Getting ariaNg...'
        cd $home_dir/Downloads && sudo -u $user_name wget https://github.com/mayswind/AriaNg/releases/download/1.2.1/AriaNg-1.2.1-AllInOne.zip
        check_return_code

        local ariangzip="$home_dir/Downloads/ariangzip"
        printf -- "Extracting ariaNg.zip into '$ariangzip'..."
        cd $home_dir/Downloads && sudo -u $user_name 7z e AriaNg-1.2.1-AllInOne.zip -oariangzip
        check_return_code

        # go back to dotfiles folder
        cd $curr_dir

        printf -- "Creating directory '~/.aria2'..."
        sudo -u $user_name mkdir $home_dir/.aria2
        check_return_code

        printf -- 'Creating empty session file...'
        sudo -u $user_name touch $home_dir/.aria2/session
        check_return_code

        printf -- "Copying config 'aria2.conf'..."
        cp install/home_config/.aria2/aria2.conf ~/.aria2/ && chown $user_name:$user_name ~/.aria2/aria2.conf
        check_return_code
        
        printf -- 'AriaNg server files setup...'
        mkdir -p /var/www/ariang/web && cp $ariangzip/index.html /var/www/ariang/web && cp install/config/var/www/ariang/nginx.conf /var/www/ariang/nginx.conf && chown -R $user_name:$user_name /var/www/ariang
        check_return_code

        # TODO: in service replace pipo with $user_name
        # TODO: also in smb.conf valid user
        # TODO: aria2.service install
        # TODO: nginx still not running nor setup for ariaNg
        # TODO: test ariaNg setup
    fi

    if [[ $samba_install == "y" ]]
    then
    	printf -- 'Installing samba server...'
    	sudo -u $user_name yay -S samba
        check_return_code
    fi

    if [[ $kodi_install == "y" ]]
    then
        if [[ $device == "rpi4" ]]
        then
            printf -- 'Installing kodi-rpi for rpi4...'
            sudo -u $user_name yay -S kodi-rpi
            check_return_code

            printf -- 'Uncommenting include kodi in config...'
            sed -i '/^#include kodi.config.txt/ s/^#//' /boot/config.txt
            check_return_code

        elif [[ $device == "rpi0" ]]
        then
            printf -- 'Installing kodi-rpi-legacy for rpi0...'
            sudo -u $user_name yay -S kodi-rpi-legacy
            check_return_code
        fi
    fi

    printf -- '\n'
}
# }}}

# Setup ufw firewall {{{
function setup_firewall() {
    if [[ $device == rpi* ]]
    then
        print_stage_banner "setup_firewall()"

        printf -- 'Enabling servicce... '
        # enable service
        systemctl enable --now ufw.service
        check_return_code

        # add rules for firewall
        printf -- 'Limiting ssh in firewall...'
        ufw limit ssh
        check_return_code

        printf -- 'Allowing Samba in firewall...'
        ufw allow CIFS
        check_return_code

        # start firewall
        printf -- 'Enabling firewall...'
        sudo ufw enable
        check_return_code

        printf -- '\n'
    fi
}
# }}}

# Setup samba server {{{
function setup_samba_server() {
    if [[ $samba_install == "y" ]]
    then
        print_stage_banner "setup_samba_server()"

        # printf -- 'Setting up samba server...'
        if [[ ! -d /etc/samba ]]
        then
            printf -- 'Creating /etc/samba dir...'
            mkdir -p /etc/samba
            check_return_code
        fi

        printf -- 'Coping config...'
        cp install/config/etc/samba/smb.conf /etc/samba/smb.conf
        check_return_code

        printf -- 'Creating samba user...'
    	useradd -s /usr/bin/nologin samba
        check_return_code

        printf -- 'Insert password for samba user...'
    	smbpasswd -a samba

    	usermod -aG samba $user_name

        printf -- 'Creating folders for samba...'
        mkdir -p /media/secure /srv/sftp/{shared,private}
        check_return_code

        # TODO:
        # add automatic creation of folder and adding it to smb.conf (template like)

        printf -- '\n'
    fi
}
# }}}

# Setup rng-tools {{{
function setup_rng_tools() {
    if [[ "$device" -eq "rpi" ]]
    then
        printf -- "Checking status of rngd...\n"
        if systemctl list-units --full -all | grep -qF "rngd.service"
        then
            printf -- "Service exists..."

            if systemctl is-active --quiet "rngd.service"
            then
                # if is active
                printf -- "Already running..."
                check_return_code
                return 0
            else
                # if inactive
                printf -- "Inactive...Starting..."
                systemctl enable --now "rngd.service"
                check_return_code
            fi
        fi

        printf -- 'Checking status of haveged...\n'
        if systemctl is-active --quiet "haveged.service"
        then
            printf "Service running...Disabling..."
            systemctl disable --now "haveged.service"
            check_return_code
        else
            printf "Already inactive..."
            check_return_code
        fi
        
        if grep -q '^RNGD_OPTS' /etc/conf.d/rngd
        then
            printf -- 'Commenting old rngd config...'
            sed -i 's/^RNGD_OPTS/#&/g' /etc/conf.d/rngd
            check_return_code
        fi

        printf -- 'Configuring rngd...'
        bash -c 'echo RNGD_OPTS=\"-o /dev/random -r /dev/hwrng -x jitter\" >> /etc/conf.d/rngd'
        check_return_code

        printf -- '\n'
    fi
}
# }}}

# Install /usr/local/bin scripts {{{
function install_usr_local_bin_scripts() {
    print_stage_banner "install_usr_local_bin_scripts()"

    printf -- 'Installing my custom scripts...'

    local BIN_SRC="./install/user_local_bin"
    local USR_LOCAL_BIN="/usr/local/bin"

    if [[ ! -d $USR_LOCAL_BIN ]]
    then
        printf -- "$USR_LOCAL_BIN doesnt exist. Creating..."
        mkdir -p $USR_LOCAL_BIN
        check_return_code
    fi

    if [[ $device == "normal" ]]
    then
        printf -- "Copying 'notification_service.ssh'..."
        cp $BIN_SRC/notification_service.sh $USR_LOCAL_BIN

    elif [[ $device == rpi* ]]
    then
        printf -- "Copying /usr/bin scripts..."
        cp -r $BIN_SRC/* $USR_LOCAL_BIN
    fi
    check_return_code

    printf -- "Making scrips in $USR_LOCAL_BIN executable..."
    chmod a+x $USR_LOCAL_BIN/*

    check_return_code

    printf -- '\n'
}
# }}}

# Install services and timers {{{
function install_services_and_timers() {
    if [[ $device == rpi* ]]
    then
        print_stage_banner "install_services_and_timers()"

        local PATH_SERVICES="./install/custom_services"
        local PATH_DEST="/etc/systemd/system/"

        # copy services and timers into /etc/systemd/system
        printf -- 'Installing services...'
        cp $PATH_SERVICES/*.service $PATH_DEST
        check_return_code
        
        printf -- 'Installing timers...'
        cp $PATH_SERVICES/*.timer $PATH_DEST
        check_return_code

        # Reload daemon after installation of services and timers
        printf -- 'Reloading service daemon...'
        systemctl daemon-reload
        check_return_code

        if [[ $auto_mount == "y" ]]
        then
            printf -- 'Enabling automnt...'
            systemctl enable --now automnt.service
            check_return_code
        fi

        if [[ $device == "rpi0" ]]
        then
            printf -- 'Enabling create_ap_at_boot...'
            systemctl enable --now create_ap_at_boot.timer
            check_return_code
        fi

        if [[ $device == rpi* ]]
        then
            printf -- 'Enabling cron_log_cpu_info...'
            systemctl enable --now cron_log_cpu_info.timer
            check_return_code

            # TODO:
            # printf -- 'Enabling notification-service...'
            # systemctl enable --now notification-service.timer
            # check_return_code
        fi

        printf -- '\n'
    fi
}
# }}}

# Setup network services {{{
function setup_network_services() {
    print_stage_banner "setup_network_services()"

    printf -- 'Masking service systemd-networkd...'
    systemctl mask systemd-networkd.service
    check_return_code

    printf -- 'Enabling service NetworkManager...'
    systemctl enable --now NetworkManager.service
    check_return_code

    printf -- '\n'
}
# }}}

# Shorted boot time for RPi by disabling services {{{
function shorten_boot_time() {
    if [[ "$shorten_boot" == "y" ]]
    then
        print_stage_banner "shorten_boot_time()"

        printf -- 'Speeding up boot...'

        printf -- 'Disabling lvm2-monitor.service...'
        # on rpi we dont need lvm and it shortends time by a lot
        systemctl mask lvm2-monitor.service
        check_return_code
        
        printf -- 'Disabling systemd-rfkill.service...'
        # also we dont need to kill any wireless devices
        # (comment if want to make HW wifi killswitch)
        systemctl mask systemd-rfkill.service
        check_return_code
        
        printf -- '\n'
    fi
}
# }}}

# Additional setup for auto-mount service {{{
function auto_mnt_service_setup() {
    if [[ $auto_mount == "y" ]]
    then
        print_stage_banner "auto_mnt_service_setup()"

        local MNT_MEDIA="/media"

        if [[ ! -d $MNT_MEDIA ]]
        then
            printf -- "Folder $MNT_MEDIA doesnt exist. Creating..."
            mkdir -p $MNT_MEDIA
            check_return_code
        fi

        printf -- 'Adding auto mount rules...'
        # create udev rules for mounting to /media
        cp "./install/custom_rules/99-udisks2.rules" "/etc/udev/rules.d/"
        check_return_code
        
        # remove mountpoints in /media on boot
        printf -- 'Adding auto delete /media folders on reboot...'
        bash -c 'echo "D /media 0755 root root 0 -" > /etc/tmpfiles.d/media.conf'
        check_return_code
        
        printf -- 'Enabling service udisks2...'
        sudo systemctl enable --now udisks2.service
        check_return_code

        printf -- '\n'
    fi
}
# }}}

# Create user kodi_autologin and install autologin override for getty@tty1 {{{
function create_kodi_autologin_user() {
    if [[ $kodi_install == "y" ]]
    then
        print_stage_banner "create_kodi_autologin_user()"

        printf -- "Creating user 'kodi_autologin'..."
        useradd -m -aG samba kodi_autologin
        check_return_code

        # TODO: maybe needs to set passwd for user kodi_autologin

        local UNIT="getty@tty1"
        local DIR="/etc/systemd/system/${UNIT}.service.d"
        
        if [[ ! -d $DIR ]]
        then
            printf -- "Directory $DIR doesnt exist. Creating..."
            mkdir $DIR
            check_return_code
        fi

        printf -- "Creating override service for $UNIT..."
        cp ./install/service_overrides/${UNIT}_override.conf $DIR/override.conf
        check_return_code

        if [[ ! -d /usr/local/bin ]]
        then
            printf -- '/usr/local/bin doesnt exist. Creating...'
            mkdir -p /usr/local/bin
            check_return_code
        fi

        # script startKodi.sh was copied in install_usr_local_bin_scripts() step
        printf -- "Installing script 'startKodi.sh' for starting kodi on boot..."
        printf -- "\n[[ -f /usr/local/bin/startKodi.sh ]] && /usr/local/bin/startKodi.sh\n" >> /home/kodi_autologin/.bashrc
        check_return_code

        printf -- '\n'
    fi
}
# }}}

function print_stages() {
    local i=1
    printf -- 'Scripts steps:\n'

    id "$user_name" &> /dev/null || print_stage $((i++)) "Create new user '$user_name'"
    print_stage $((i++)) "Configure user $user_name"
    print_stage $((i++)) "Configure locale"
    print_stage $((i++)) "Configure time zone"
    print_stage $((i++)) "Configure colorful pacman"
    print_stage $((i++)) "Configure boot configs"
    print_stage $((i++)) "Install sudo"
    print_stage $((i++)) "Configure sudoers"
    print_stage $((i++)) "Install yay"
    print_stage $((i++)) "Install packages"
    print_stage $((i++)) "Setup firewall"
    [[ $samba_install == "y" ]] && print_stage $((i++)) "Setup samba server"
    [[ $device == rpi* ]] && print_stage $((i++)) "Setup rng tools [rpi]"
    print_stage $((i++)) "Install usr scripts"
    print_stage $((i++)) "Install services and timers"
    print_stage $((i++)) "Setup network services"
    [[ $shorten_boot == "y" ]] && print_stage $((i++)) "Shorten boot time by disabling services"
    [[ $auto_mount == "y" ]] && print_stage $((i++)) "Setup auto-mount service for storages"
    print_stage $((i++)) "Create kodi_autologin user"

    printf -- '\n'

    read -p 'Press Enter to continue.'
    printf -- '\n'
}

# Print stages before running stages
print_stages

# Run stages
create_new_user
configure_user
configure_locale
configure_time_zone
configure_colorful_pacman
configure_boot
install_sudo        # install sudo
configure_sudoers   # configure sudoers before installing yay and other stages that require pipo in sudo
install_yay
install_packages
setup_firewall
setup_samba_server
setup_rng_tools
install_usr_local_bin_scripts
install_services_and_timers
setup_network_services
shorten_boot_time
auto_mnt_service_setup
create_kodi_autologin_user

printf -- "\n\n${TEXT_BOLD}${COLOR_GREEN}"
print_banner "Everything is Done!\n"
printf -- "$COLOR_RESET"

if [[ $ariaNg_setup == "y" ]]
then
    printf -- "To ariaNg web add secret token to UI.\n"
    printf -- "To aria2 create token with '${COLOR_LIGHT_BLUE}openssl rand -base64 32${COLOR_RESET}'. Replace in config '~/.aria2/aria2.conf' string '**secret**'\n"
fi
