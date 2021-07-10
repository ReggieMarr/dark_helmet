# Environment Setup

## Connect to Wifi

Wireless Network: L3_Guest
Key: L-3Gu3stW!F!

## Link git config

```bash
cd ~
ln -s ~/Dropbox/environment/.gitconfig
```

## Beyond Compare 4

Althought this software is expensive.. I find it a super worthwhile tool to have in my toolbox & the license is a 1 time buy that you can use as many times as you like!

- Install from website
- Register key
- Executable should be located at /usr/bin/bcompare
- Configure **GIT** to use as default diff and merge tool
- Add to the \~/.gitconfig (if not already added)

```bash
[diff]
        tool = bc4
[difftool]
        prompt = false
[difftool "bc4"]
        trustExitCode = true
        cmd = `/usr/bin/bcompare $LOCAL $REMOTE`
[merge]
        tool = bc4
[mergetool]
        prompt = false
[mergetool "bc4"]
        trustExitCode = true
        cmd = `/usr/bin/bcompare $LOCAL $REMOTE $BASE $MERGED`
```

- To allow directory compare with git and beyond comapre, you must configure BC4 such that is can follow symbolic links. This will align symlinks with files of the same name.
    - In the **Folder Compare**, click the **Rules** toolbar button (referee icon). Go to the **Handling** tab. Check **Follow symbolic links**.

## Foxit Reader

- Download latest Foxit Reader .tar.gz from https://www.foxitsoftware.com/pdf-reader/
- Extract and run the .run
- Follow wizard to install

```
cd ~/Downloads
gzip -d FoxitReader_version_Setup.run.tar.gz
tar -xvf FoxitReader_version_Setup.run.tar
./FoxitReader_version_Setup.run
```

## Swap Esc and Caps Lock as well as left alt & win keys

Since we all know that esc is WAY more useful than capslock.. why not switch them and make it more accessible?

A temporary way to do this is by invoking:
setxkbmap -option caps:swapescape 
setxkbmap -option altwin:swap_lalt_lwin 

An alternate permanent way is through the dconf-editor. This method has a few extra steps from gnome-tweak-tool, but is useful if you don't want to pull in the dependencies from the tweak tool.

This will allow you to use the caps:swapescape syntax and automatically make the change permanent.

lv3:ralt_switch?? I don't know why this was in my config?

```bash
sudo apt-get install dconf-tools
```

After starting the dconf-editor, navigate to ***org >> gnome >> desktop >> input-sources***

Add the options that you need in xkb-options. The option strings are surrounded by single quotes and separated by commas. **Be careful not to delete the brackets on the ends**.

in this case it should look like ['caps:swapescape', 'altwin:swap_lalt_lwin']

the list of all posibble options can be found in /usr/share/X11/xkb/rules/evdev.lst



## Disable cttrl+shift+u shortcut

- Open Search using Super key
- Type "language support" and hit ENTER
- Click the "Keyboard input method system" dropdown menu and select "XIM"
- No need to click system wide
- Reboot

## Other system-wide shortcuts

Navigate to keyboard shortcuts in search pane (just typing shortcuts should work or settings->devices->keyboard)

|                  Command                  |   Shortcut  |
|-------------------------------------------|-------------|
| Switch applications                       | Ctrl+Return |
| Copy a screenshot of an area to clipboard | Ctrl+Print  |
|                                           |             |

### Network adapter switching

To  (used for goolgle search sublime plugin) we execute

Install ifconfig:
`sudo apt install net-tools`

allow the ifconfig command to work without sudo privileges
`chmod 4755 /sbin/ifconfig`

Enable and disable the wifi network adapter via a function key:

- Open keyboard options & create a custom shortcut
    - Shortcut 1
        - Name: intranet
        - Command: sh -c "ifconfig enp0s31f6 up && ifconfig wlp2s0 down"
        - Shortcut: F11
    - Shortcut 2
        - Name: internet
        - Command: sh -c "ifconfig enp0s31f6 down && ifconfig wlp2s0 up"
        - Shortcut: F12

## Setup Some Custom Mime Types

Set up some custom mime types to allow ubuntu to recognize uncommon file types

- navigate to setup/mime_types and paste the contents of this folder in /user/share/mime/packages
- reset the database with:
    - sudo update-mime-database /usr/share/mime



## Adding Bookmarks Nautilus File Explorer

- Open ~/.config/gtk-3.0/bookmarks
- Add

## Other programs

- GIMP
- Foxit Reader?
- Draw IO

|   Program   |                                      Install Instructions                                      |
|-------------|------------------------------------------------------------------------------------------------|
| GIMP        | Ubuntu SW Center                                                                               |
| Draw IO     | deb: https://github.com/jgraph/drawio-desktop/releases/download/v9.3.1/draw.io-amd64-9.3.1.deb |
| Virtual Box | Ubuntu SW Center                                                                               |
| Mattermost  | Ubuntu SW Center                                                                               |
|             |                                                                                                |

## Mozilla Customizations

## Install GDB

- Download and unzip gnu-mcu-eclipse-arm-none-eabi-gcc-8.2.1-1.4-20190214-0604-centos64.tgz from https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc/releases
- navigate to /gnu-mcu-eclipse-arm-none-eabi-gcc-6.3.1-1.1-20180331-0618-centos64/gnu-mcu-eclipse/arm-none-eabi-gcc/6.3.1-1.1-20180331-0618/bin
- Copy the GDB and objcopy into /usr/bin
    - sudo cp arm-none-eabi-gdb /usr/bin/
    - sudo cp arm-none-eabi-objcopy /usr/bin/

## Install Giffing -> screen capture to gif tool

- sudo apt install ffmpeg graphicsmagick gifsicle luarocks cmake compiz gengetopt slop libxext-dev libimlib2-dev mesa-utils libxrender-dev glew-utils libglm-dev libglu1-mesa-dev libglew-dev libxrandr-dev libgirepository1.0-dev
- sudo luarocks install lgi
- sudo luarocks install --server=http://luarocks.org/dev gifine

- Now you can run Gifine with the command gifine

## Change Lid Close Behavior

- vi /etc/systemd/logind.conf
    - uncomment/paste
        - HandleLidSwitch=suspend
        - HandleLidSwitchDocked=suspend
    - systemctl restart systemd-logind.service

- If the laptop still isn't suspending (it is shutting down and rebooting instead) try the following
    - vi /etc/default/grub
    - Look for the line that says: GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
    - And change it to:            GRUB_CMDLINE_LINUX_DEFAULT="quiet splash acpi_sleep=nonvs"
    - Then run:                    sudo update-grub
    - Reboot and enjoy!


## Install Docker

- SSH from within Docker
    - Be sure to mount .ssh folder in docker by adding command `-v $HOME/.ssh:/root/.ssh:ro` when launching docker
    - If you have problems with `Bad owner or permissions`
        - Try `chown root ~/.ssh/config`

## Install zsh

- Install zsh
    - sudo apt install zsh
    - ln -s ~/Dropbox/environment/zsh/.zshrc
    - To set Zsh as default shell enter:
        - chsh -s /bin/zsh
    - Logout and back in

- Install oh-my-zsh
    - sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    - ln -s ~/Dropbox/Environment/zsh/.oh-my-zsh

- Install powerLevel9ki
    - sudo apt-get install fonts-powerline
    - cd $HOME
    - You can either: git clone https://github.com/bhilburn/powerlevel9k.git ~/powerlevel9k
    - Or you can symlink to the dropbox
        - navigate to home: cd $HOME
        - ln -s ~/Dropbox/Environment/zsh/powerlevel9k


## Sublime Setup

### 3rd Party Plugins

- sublime_zk
    - Provides Id-based, Wiki-style linkings and #tags in documents
    - INSTALL
        - Package Control: Add Repository
        - Add the URL of this repository https://github.com/renerocksai/sublime_zk into the panel that appears at the bottom of the window and press Enter
        - Use the Command Palette and run Package Control: Install Package and search for sublime_zk from the list of available packages. Select it and press Enter to install the package
    - Project and README can be found at https://github.com/renerocksai/sublime_zk
    - add to sublime_zk.sublime-settings
        - "auto_show_images": true, //display images automatically in doc file

- Calculate
- EasyClangComplete
    - Need to install Clang to work
        - sudo apt-get install clang
- Fold Comments
- Git Blame
- Guna -> Theme for sublime
- Move By Symbols
- Origami
- Side Bar Enhancements
- Sublime Git
- Table Editor
- Terminus
- VAlign
- Word Highlight

- Reinstall?
    - BracketHighlighter
    - CommentSnippets
    - CTags
    - FileDiffs
    - Git Time Metric
    - Go to Definition
    - List Open Files
    - Materialize
    - Non Text Files

## LSP & TabNine for C/C++
    - Install clangd language server
        - sudo apt-get install clangd-9
    - Install LSP from sublime package manager
    - Make sure LSP user plugin settings have been copied from dropbox
        - This will have a clangd entry and enable the LSP server for clangd to to run for any C/C++ related files 
    
    - TabNine also relies on Clangd for semantic completions
    - Install Tabnine using Sublime's Package Manager
    - Enable semantic completion by opening a C/C++ files and just typing in the file "TabNine::sem" (w/o quotes)
    - This will enable semantic completion for this file type
    
    - Connect clangd to tabnine
        - We most likely need to manually connect tabnine to clangd
        - TODO instruction -> symlink in .toml file from dropbox to ~/.config/TabNine/TabNineExample.toml
    
### Custom plugins

- copy-table
    - Must have TKinter installed

