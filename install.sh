if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [[ -d "/usr/bin/scmpv" ]]; then
    echo -e "/usr/bin/scmpv already exist. use uninstall.sh first"
    exit 1
fi
chmod +x scmpv.sh
cp -a scmpv.sh /usr/bin/scmpv
echo -e "Done."
