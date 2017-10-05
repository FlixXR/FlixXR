#/bin/bash
packagelist=/tmp/packages.txt

echo "Checking for Updates"
apt-get update && apt-get -yq dist-upgrade && apt-get clean

echo "Creating Directory Structure..."
mkdir -p /var/www/{rutorrent,organizr} \
&& mkdir -p /srv/downloads/{complete,incomplete,watch,convert} \
&& mkdir -p /srv/media/{'Kids TV Shows',Movies,'TV Shows','Kids Movies'}

cd /tmp \
&& wget https://raw.githubusercontent.com/FlixXR/Media-Server/master/packages.txt \
&& echo "Installing and Updating Required Dependencies.."
xargs -a <(awk '! /^ *(#|$)/' "$packagelist") -r -- apt-get -yqq install

#clone repo
git clone https://github.com/flixxr/flixxr /tmp/configs \
&& name=$(whiptail --inputbox "Enter your root domain [i.e example.com not www.example.com]" 15 45 3>&1 1>&2 2>&3) \
&& echo "Is $name correct?" > /dev/null 2>&1 \
&& whiptail --ok-button Continue --msgbox "Using $name for our domain" 10 30 \
&& grep -rl example.com /tmp/configs | xargs sed -i 's/example.com/$name/g'

echo "Installing our Apps.."
sleep 1
echo "Organizr"
git clone https://github.com/causefx/Organizr /var/www/organizr
sleep 2

echo "Ombi aka Plex Requests"
mkdir /opt/Ombi && cd /opt \
&& wget https://github.com/tidusjar/Ombi/releases/download/v2.2.1/Ombi.zip \
&& sudo unzip Ombi.zip -d /opt/Ombi && rm -f Ombi.zip
sleep 2

echo "PlexPy - Plex Stats"
git clone https://github.com/JonnyWong16/plexpy.git plexpy
sleep 2

echo "Radarr - Automatically grabs Movies for Download via Usenet and Torrent"
wget https://github.com/Radarr/Radarr/releases/download/v0.2.0.852/Radarr.develop.0.2.0.852.linux.tar.gz \
&& tar -xvzf Radarr.develop.*.linux.tar.gz \
&& rm Radarr.develop.*.linux.tar.gz
sleep 2

echo "Couchpotato - An alternative to Radarr"
pip install --upgrade pyopenssl \
&& git clone https://github.com/CouchPotato/CouchPotatoServer.git couchpotato
sleep 2

echo " Sonarr - Automatically grabs TV Shows for Download via Usenet/Torrent"
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC \
&& echo "deb http://apt.sonarr.tv/ master main" | sudo tee /etc/apt/sources.list.d/sonarr.list > /dev/null 2>&1 \
&& apt-get -yqq update && apt-get -yqq install nzbdrone
sleep 2

echo "Jackett - Integrates Public Torrent Trackers into Sonarr/Radarr"
wget -q https://github.com/Jackett/Jackett/releases/download/v0.8.237/Jackett.Binaries.Mono.tar.gz \
&& tar -xvzf Jackett.Binaries.Mono.tar.gz \
&& mv Jackett jackett
sleep 2

echo "Nzbhydra - Usenet Search Engine aka Usenet Google"
git clone https://github.com/theotherp/nzbhydra nzbhydra
sleep 2

echo "Nzbget - Our Usenet Downloader"
wget https://nzbget.net/download/nzbget-latest-bin-linux.run \
&& sh nzbget-latest-bin-linux.run \
&& rm nzbget-latest-bin-linux.run
sleep 2

echo "rTorrent + ruTorrent + Flood - our Torrent Downloader with 2 web UI's"
apt -yqq install rtorrent \
&& git clone https://github.com/Novik/ruTorrent.git /var/www/rutorrent \
&& git clone https://github.com/jfurrow/flood.git /var/www/flood \
&& wget https://nodejs.org/download/release/v7.4.0/node-v7.4.0.tar.gz \
&& tar xvf node-v7.4.0.tar.gz \
&& rm -f node-v7.4.0.tar.gz \
&& cd node-v7.4.0 \
&& ./configure \
&& make -j2 \
&& make install \
&& cd /var/www/flood \
&& cp /tmp/configs/flood/config.js . \
&& npm install --production \
&& mkdir -p /opt/rtorrent/session \
&& cp /tmp/configs/rtorrent/rtorrent.rc /opt/rtorrent
sleep 2

echo "ruTorrent Plugins"
cd /var/www/rutorrent \
&& rm -r plugins \
&& svn checkout https://github.com/Novik/ruTorrent/trunk/plugins plugins \
&& cd plugins \
&& wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/rutorrent-tadd-labels/lbll-suite_0.8.1.tar.gz \
&& tar zxvf lbll-suite_0.8.1.tar.gz \
&& rm lbll-suite-0.8.1.tar.gz \
&& git clone https://github.com/xombiemp/rutorrentMobile.git mobile \
&& git clone https://github.com/autodl-community/autodl-rutorrent.git autodl-irssi \
&& cp autodl-irssi/_conf.php autodl-irssi/conf.php \
&& cd /var/www/rutorrent/conf \
&& mv config.php config.php.bk \
&& mv plugins.ini plugins.ini.bk \
&& cp /tmp/configs/rutorrent/{plugins.ini,config.php} . 

echo "grabbing ruTorrent Themes"
cd /var/www/rutorrent/plugins/theme/themes \
&& svn co https://github.com/ArtyumX/ruTorrent-Themes/trunk/OblivionBlue oblivionblue \
&& svn co https://github.com/ArtyumX/ruTorrent-Themes/trunk/MaterialDesign  material \
&& svn co https://github.com/ArtyumX/ruTorrent-Themes/trunk/FlatUI_Dark flatdark \
&& svn co https://github.com/ArtyumX/ruTorrent-Themes/trunk/FlatUI_Material flatmaterial \
&& svn co https://github.com/ArtyumX/ruTorrent-Themes/trunk/club-QuickBox quickbox \
&& sudo perl -pi -e "s/\$defaultTheme \= \"\"\;/\$defaultTheme \= \"material\"\;/g" /var/www/html/rutorrent/plugins/theme/conf.php

echo "Wetty - Terminal in a Web Browser"
git clone https://github.com/krishnasrinivas/wetty /opt/wetty \
&& cd /opt/wetty \
&& npm install 
sleep 2

echo "Cloudcmd - File Manager in a Web Browser"
npm install -g cloudcmd
sleep 2

echo "Plex-Board - Monitors Status of Our Apps"
apt-add-repository -y ppa:rael-gc/rvm \
&& apt-get update && apt-get -yqq install rvm \
&& source /etc/profile.d/rvm.sh \
&& rvm install 2.4.2 \
&& git clone https://github.com/scytherswings/Plex-Board.git /var/www/plexboard \
&& cd /var/www/plexboard \
&& sh serverSetup.sh

echo "Setting up Web Server..."
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bk \
&& unlink /etc/nginx/sites-enabled/default \
&& mv /etc/nginx/sites-available/default /etc/nginx/default_vhost.bk \
&& cp -r /tmp/configs/nginx/* /etc/nginx/ \
&& cd /etc/nginx/sites-enabled/ \
&& cp -s /etc/nginx/sites-available/* .

echo "Configuring Services.."
cp /tmp/configs/systemd/* /etc/systemd/system/ \
&& ls -A1 /tmp/configs/systemd | xargs systemctl enable --now

echo "Last but not Least. Installing Plex"
git clone https://github.com/mrworf/plexupdate.git /opt/plexupate \
&& cd /opt/plexupdate \
&& cat >> plexupdate.conf << EOF
AUTOINSTALL=yes
AUTOUPDATE=yes
CHECKUPDATE=yes
DOWNLOADDIR=/opt/plexupdate
FORCE=no
FORCEALL=no
LOGGING=false
NOTIFY=no
PUBLIC=yes
PLEXSERVER=127.0.0.1
PLEXUPDATE=32400
EOF

## Config Set...Installing Plex
./plexupdate.sh -vP --config /opt/plexupdate/plexupdate.conf

echo "LetsEncrypt for HTTPS on our sites"
git clone https://github.com/Neilpang/acme.sh.git /opt/letsencrypt \
&& cd /opt/letsencrypt \
&& systemctl stop nginx.service \
&& ./acme.sh --install \
&& exec bash --login \
&& cd /opt/letsencrypt \
&& ./acme.sh --issue -d "$name" --standalone -d www."$name" -d couchpotato."$name" \
-d dash."$name" -d flood."$name" -d hydra."$name" -d jackett."$name" -d nzbget."$name" -d plex."$name" \
-d plexpy."$name" -d radarr."$name" -d requests."$name" -d rtorrent."$name" -d shell."$name" -d sonarr."$name"

if whiptail --yesno "Was our letsencrypt request succesfull" 20 60 ;then
    echo "Awesome. Restarting services and were done" \
    && grep -rl '#' /etc/nginx/sites-available/ | xargs sed -i '' 's/^#\(.*\)/\1/g' \
    && systemctl start nginx 
else
    echo "please fix any errors and rerun the script"
fi









