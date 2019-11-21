t# Handling Virtual Machines

1- Mkdir and cd into the dir
2- `vagrant init ubuntu/trusty64`

#### Vagrant Commands

  - `vagrant status`
  - `vagrant suspend`
  - `vagrant up`
  - `vagrant ssh` connects and log you into the vm
  -  `vagrant halt`
  - `vagrant destroy`

3- `vagrant ssh` log into the vm (home dir)
4- `ls -al` to list the content of the dir. any line starting with `d` is a directory and any line starting with `-` is a file. (al -all files in long format).

`/root/` is the root users home dir

echo `$PATH`
etc =  where configuration files live
var = variable files for files will change their size, used for storing log files
bin = executable binaries that are accessed by all users
sbin = system binaries used by admin for maintenance of the system
lib = libaries that support the binaries that are located around the system
usr = user programs

http://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html

difference btw bin and usr is that, binaries in bin are required for bootup and system maintenance processes 
https://askubuntu.com/questions/60218/how-to-add-a-directory-to-the-path

echo $path

when we type a command as ls, it looks for the binary in all the listed files


`cat /etc/apt/sources.list` to see all packages
`sudo apt-get update` to get your vm aware all the softwares and packages installed
`sudo apt-get upgrade` to actually update all the softwares
`man apt-get` to get more info about apt-get command
`sudo apt-get autoremove`

`sudo apt-get finger` install finger app

packages.ubuntu.com

type `finger` to list all the currently logged in users
`finger vagrant` to view more information about the vagrant user

`cat /etc/passwd` view a file that stores users information
each line in this file represents a single user
`vagrant:x:1000:1000::/home/vagrant:/bin/bash` => `vagrant` is users username
`x` - stores encrypted password
`1000:1000` - stores users id and groups id
`::` gives a better description of the user
`/home/vagrant` users home dir
`/bin/bash` users default shell

## Creating New User

`sudo adduser <username>` and supply the requested info

### connecting our new user

from new terminal window,

`ssh tvpeter@127.0.0.1 -p 2222` 

or 

`ssh tvpeter@<privateIpAddress> -p 22`

`ssh` is the application we use to connect to the remote server
`127.0.0.1` is the ip address we want to connect to
`tvpeter@` is the username we want to log in
`-p 2222` is the port we are using to connect

all users permissions are stored in `/etc/sudoers`

#### adding our user to the sudoers group

first ls the files in the dir `/etc/sudoers.d`
cp the `vagrant` and modify it to the new username to be granted permission same as vagrant user

`sudo cp /etc/sudoers.d/vagrant /etc/sudoers.d/tvpeter`
`sudo nano /etc/sudoers.d/tvpeter`
`sudo passwd -e [username] ` forces the user to change their password the next time they login


### Keybased authentication

Creating users with password is easy to crack since passwords are short and can be memorized.

on the local system, generate the keys using `ssh-keygen` and store it in `/users/[username]/.ssh/fileName

it will generate two keys wih the given file name one ending with .pub, the `.pub` is what we will place on the server

### using the generated key to log in

login as the new user

create, `mkdir .ssh` in the home dir
then `touch .ssh/authorized_keys` to create a new file

on the local machine, view the contents of the `.pub` file and copy the key 

as the new user, edit the authorized_keys file and save the copied key

then we will set permissions on the `authorized_keys` file not to allow other users have access to the file

`chmod 700 .ssh`
`chmod 644 .ssh/authorized_keys`

with the above, lets login with the keys

`ssh tvpeter@127.0.0.1 -p 2222 -i ~/.ssh/linuxcourse`

### disable password-based logins

on the server, edit the config file `sudo nano /etc/ssh/sshd_config` and change `PasswordAuthentication yes` to `PasswordAuthentication no`
and restart the service `sudo service ssh restart`

### FILE permissions

`-rw-r--r-- 1 tvpeter tvpeter  675 Sep 30 06:53 .profile`
`-` indicates its a file

`rw-` owner = read write Cannot execute
`r--` group = group users can read, cannot write, canno execute
`r--` everyone = everyone can read, cannot write, cannot execute
`tvpeter` = username
`tvpeter` = group name

`r` read = 4
`w` write = 2
`x` execute = 1
to indicate that a no, we use `0`

so the file permission for this line `-rw-r--r-- 1 tvpeter tvpeter  675 Sep 30 06:53 .profile` is 
                                       4+2 2  1  = 621 (octa format)
                                       permissions are in sets of 3 = owner, group and everyone

CHMOD = change file permission
CHOWN = CHANGE owner
CHGRP = change group

`sudo chgrp root .bash_history` change the group to root
`sudo chown root .bash_history` change the owner to root

### Introduction to ports

HTTP = 80
SMTP = 25
FTP = 21
SSH = 22
HTTPS = 443
POP3 = 110

### Firewall Configuration

- ubuntu comes with a preinstalled firewall manager called `ufw`
type `sudo ufw status` to check its status
`sudo ufw default deny incoming ` to deny incoming requests to allow us config the firewall
`sudo ufw default allow outgoing` allow the server to send outgoing requests
`sudo ufw allow ssh`
`sudo ufw allow 2222/tcp`
`sudo ufw allow www`

Open the Vagrantfile in your project directory and look for the following section near lines 20-23:

`# Create a forwarded port mapping which allows access to a specific port
# within the machine from a port on the host machine. In the example below,
# accessing "localhost:8080" will access port 80 on the guest machine.
# config.vm.network "forwarded_port", guest: 80, host: 8080 `

Uncomment the last line:

config.vm.network "forwarded_port", guest: 80, host: 8080
Save the file and start your Vagrant virtual machine using the vagrant up command. If your virtual machine is currently running, you can reload it using the vagrant reload command.

####  SETTING UP APACHE WEB SERVER

Install Apache using your package manager with the following command: sudo `apt-get install apache2`
 Confirm Apache is working by visiting `http://localhost:8080` in your browser. You should see a page.

Apache, by default, serves its files from the `/var/www/html` directory. If you explore this directory you will find a file called index.html and if you review that file you will see it contains the HTML of the page you see when you visit http://localhost:8080.


The configuration layout for an Apache2 web server installation on Ubuntu systems is as follows:

/etc/apache2/
|-- apache2.conf
|       `--  ports.conf
|-- mods-enabled
|       |-- *.load
|       `-- *.conf
|-- conf-enabled
|       `-- *.conf
|-- sites-enabled
|       `-- *.conf
          
apache2.conf is the main configuration file. It puts the pieces together by including all remaining configuration files when starting up the web server.
ports.conf is always included from the main configuration file. It is used to determine the listening ports for incoming connections, and this file can be customized anytime.
Configuration files in the mods-enabled/, conf-enabled/ and sites-enabled/ directories contain particular configuration snippets which manage modules, global configuration fragments, or virtual host configurations, respectively.
They are activated by symlinking available configuration files from their respective *-available/ counterparts. These should be managed by using our helpers a2enmod, a2dismod, a2ensite, a2dissite, and a2enconf, a2disconf . See their respective man pages for detailed information.
The binary is called apache2. Due to the use of environment variables, in the default configuration, apache2 needs to be started/stopped with /etc/init.d/apache2 or apache2ctl. Calling /usr/bin/apache2 directly will not work with the default configuration.