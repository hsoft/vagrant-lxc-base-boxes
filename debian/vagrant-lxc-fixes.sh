#!/bin/bash
set -e
source /etc/profile

# Fixes some networking issues
# See https://github.com/fgrehm/vagrant-lxc/issues/91 for more info
if ! $(grep -q 'ip6-allhosts' /etc/hosts); then
  echo 'ff02::3 ip6-allhosts' >> /etc/hosts
fi

# Ensure locales are properly set, based on http://askubuntu.com/a/238063
LANG=${LANG:-en_US.UTF-8}
sed -i "s/^# ${LANG}/${LANG}/" /etc/locale.gen

# Fixes some networking issues
# See https://github.com/fgrehm/vagrant-lxc/issues/91 for more info
sed -i -e "s/\(127.0.0.1\s\+localhost\)/\1\n127.0.1.1\t${CONTAINER}\n/g" /etc/hosts

# Fixes for jessie, following the guide from
# https://wiki.debian.org/LXC#Incompatibility_with_systemd
if [ "$RELEASE" = 'jessie' ] || [ "$RELEASE" = 'stretch' ]; then
    # Reconfigure the LXC
    cp /lib/systemd/system/getty@.service /etc/systemd/system/getty@.service
	# Comment out ConditionPathExists
	sed -i -e 's/\(ConditionPathExists=\)/# \n# \1/' \
	    "/etc/systemd/system/getty@.service"

	# Mask udev.service and systemd-udevd.service:
	systemctl mask udev.service systemd-udevd.service
fi

locale-gen ${LANG}
update-locale LANG=${LANG}
