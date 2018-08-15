#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "Please run this script as root" 1>&2
	exit 1
fi

echo "Ensure port 80 and 443 are available in IPTables."
read -p "Please ensure your hosts file and DNS is properly configured with A and MX records before proceeding. Y to continue: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
	exit 1
fi

#Start with installing sendmail
echo "Installing necessary tools"
#apt-get -y install sendmail git apache2 opendkim opendkim-tools libmilter-dev screen
# Removed apache from install
apt-get update
apt-get -y install sendmail git opendkim opendkim-tools libmilter-dev screen

#Change opendkim-genkey to create 1024 bit certs
sed -i 's/2048/1024/g' /usr/bin/opendkim-genkey
 
echo "Enter the domains you want to add https to, seperated by commas."
echo "The first domain should be your mail server: " 
IFS=', ' read -r -a domains
echo "define(\`confDOMAIN_NAME', \`${domains[0]}')" >> /etc/mail/sendmail.mc
echo "define(\`confHELO_NAME', \`${domains[0]}')" >> /etc/mail/sendmail.mc
echo "${domains[0]}" >> /etc/mail/local-host-names

# #########################
# ### LETSENCRYPT SETUP ###
# #########################
# #Git clone letsencrypt and generate our certs for all domains
# echo "Starting LetsEncrypt setup"
# cd /opt/
# git clone https://github.com/letsencrypt/letsencrypt.git
# service apache2 stop
# cd letsencrypt
# cmd="./letsencrypt-auto certonly --standalone"
# for each in "${domains[@]}"
# do
# 	cmd="$cmd -d $each"
# done
# $cmd

# #Set up the apache vhost
# cat << EOF >> /etc/apache2/sites-enabled/000-default.conf
# <VirtualHost *:443>
# 	ServerName ${domains[0]}
# 	DocumentRoot /var/www/html
# 	ErrorLog ${APACHE_LOG_DIR}/error.log
# 	CustomLog ${APACHE_LOG_DIR}/access.log combined
# 	SSLEngine on
# 	SSLProtocol	all -SSLv2 -SSLv3
# 	SSLCipherSuite	ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA
# 	SSLHonorCipherOrder on
# 	SSLCompression off
# 	SSLOptions +StrictRequire
# 	Header always set Strict-Transport-Security "max-age=15768000"

# 	SSLCertificateFile "/etc/letsencrypt/live/${domains[0]}/cert.pem"
# 	SSLCertificateKeyFile "/etc/letsencrypt/live/${domains[0]}/privkey.pem"
# 	SSLCertificateChainFile	"/etc/letsencrypt/live/${domains[0]}/chain.pem"
# </VirtualHost>
# EOF

# #Enable ssl on the server
# cp /etc/apache2/mods-available/ssl.* /etc/apache2/mods-enabled/
# cp /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/
# cp /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/


#########################
####  OPENDKIM SETUP ####
#########################
#Write /etc/opendkim.conf
cat << EOF > /etc/opendkim.conf
AutoRestart			Yes
AutoRestartRate		10/1h
Umask				002
Syslog				yes
SyslogSuccess		Yes
LogWhy				Yes
Canonicalization	relaxed/simple
ExternalIgnoreList	refile:/etc/opendkim/TrustedHosts
InternalHosts		refile:/etc/opendkim/TrustedHosts
KeyTable			refile:/etc/opendkim/KeyTable
SigningTable		refile:/etc/opendkim/SigningTable
Mode				sv
PidFile				/var/run/opendkim/opendkim.pid
SignatureAlgorithm	rsa-sha256
UserID				opendkim:opendkim
Socket				inet:12301@localhost
EOF

#Connect sendmail to opendkim
echo "INPUT_MAIL_FILTER(\`opendkim', \`S=inet:12301@localhost')" >> /etc/mail/sendmail.mc
sed -i "/define(\`confCONNECTION_RATE_WINDOW_SIZE',\`10m')dnl/c\define(\`confCONNECTION_RATE_WINDOW_SIZE',\`30s')dnl" /etc/mail/sendmail.mc
echo "define(\`confRECEIVED_HEADER',\`by $j ($v/$Z)$?r with $r$. id $i; $b')dnl" >> /etc/mail/sendmail.mc

#Add necessary files for opendkim
mkdir -p /etc/opendkim/keys
echo "mail._domainkey.${domains[0]} ${domains[0]}:mail:/etc/opendkim/keys/${domains[0]}/mail.private" >> /etc/opendkim/KeyTable

echo "Enter a list of trusted domains/ips outside localhost for sending mail (comma seperated, blank if just localhost): "
IFS=', ' read -r -a trusted
cat << EOF > /etc/opendkim/TrustedHosts
127.0.0.1
localhost
${domains[0]}
EOF

if [[ ${#trusted[@]} -ne 0 ]]; then
	for each in "${trusted[@]}"
	do
		echo $each >> /etc/opendkim/TrustedHosts
		echo "Connect:$each RELAY" >> /etc/mail/access
	done
fi

makemap hash /etc/mail/access < /etc/mail/access

read -p "Enter an address to forward mail to (blank for none): " email
if [[ $email != "" ]]; then
	echo "@${domains[0]} ${email}" >> /etc/mail/virtusertable
	makemap hash /etc/mail/virtusertable < /etc/mail/virtusertable
	sed -i "/FEATURE(\`access_db', , \`skip')dnl/aFEATURE(\`virtusertable', \`hash -o /etc/mail/virtusertable.db')dnl" /etc/mail/sendmail.mc
	sed -i "/DAEMON_OPTIONS(\`Family=inet,  Name=MTA-v4, Port=smtp, Addr=127.0.0.1')dnl/c\DAEMON_OPTIONS(\`Family=inet,  Name=MTA-v4, Port=smtp')dnl" /etc/mail/sendmail.mc
fi

echo "*@${domains[0]} mail._domainkey.${domains[0]}" >> /etc/opendkim/SigningTable

#Make our dkim keys
cd /etc/opendkim/keys
mkdir ${domains[0]}
cd ${domains[0]}
cmd="opendkim-genkey -s mail"
for each in "${domains[@]}"
do
	cmd="$cmd -d $each"
done
$cmd

chown -R opendkim:opendkim /etc/opendkim/
dkimrecord="$(cat *.txt | cut -d '"' -f 2)"

#########################
####### SRS SETUP #######
#########################
cd /opt
wget http://downloads.sourceforge.net/project/pymilter/pysrs/pysrs-0.30.11/pysrs-0.30.11.tar.gz
tar zxvf pysrs-0.30.11.tar.gz
rm pysrs-0.30.11.tar.gz
mv pysrs-0.30.11 pysrs
cp pysrs/pysrs.m4 /usr/share/sendmail/cf/hack/
mkdir -p /var/run/milter
touch /var/run/milter/pysrs
read -p "Enter a secret for SRS (single word string of your choice)?" secret
cat << EOF > /etc/mail/pysrs.cfg
[srs]
secret="${secret}"
maxage=21
hashlength=5
# if defined, SRS uses a database for opaque rewriting
;database=/var/log/milter/srsdata
# sign these domains using SES to prevent forged bounces instead of SRS
;ses = localdomain1.com, localdomain2.org
# sign these domains using SRS in signing mode to prevent forged bounces 
;sign = localdomain1.com, localdomain2.org
# rewrite all other domains to this domain using SRS
fwdomain = ${domains[0]}
# reject unsigned mail to these domains in pymilter (not used by pysrs)
;srs = otherdomain.com
EOF
echo "define(\`NO_SRS_FROM_LOCAL')dnl" >> /etc/mail/sendmail.mc
echo "HACK(\`pysrs', \`/var/run/milter/pysrs')dnl" >> /etc/mail/sendmail.mc
screen -d -m python /opt/pysrs/pysrs.py /var/run/milter/pysrs

make -C /etc/mail/
service opendkim restart
service sendmail restart

numfields="$(echo ${domains[0]} | tr '.' '\n' | wc -l)"

if [[ $numfields -eq 2 ]]; then
	echo "Add the following entries to your DNS for ${domains[0]}"
	echo "Namecheap Entries"
	echo "@ TXT: v=spf1 +mx +a -all"
	echo "mail._domainkey.@ TXT: ${dkimrecord}"
	echo ""
	echo "Gandi Entries"
	echo "@ 300 IN SPF \"v=spf1 +mx +a -all\""
	echo "@ 300 IN TXT \"v=spf1 +mx +a -all\""
	echo "mail._domainkey.@ 300 IN TXT \"${dkimrecord}\""
else
	prefix="$(echo ${domains[0]} | rev | cut -d '.' -f 3- | rev)"
	echo "Add the following entries to your DNS for ${domains[0]}"
	echo "Namecheap Entries"
	echo "${prefix} TXT: v=spf1 +mx +a -all"
	echo "mail._domainkey.${prefix} TXT: ${dkimrecord}"
	echo ""
	echo "Gandi Entries"
	echo "${prefix} 300 IN SPF \"v=spf1 +mx +a -all\""
	echo "${prefix} 300 IN TXT \"v=spf1 +mx +a -all\""
	echo "mail._domainkey.${prefix} 300 IN TXT \"${dkimrecord}\""
fi
