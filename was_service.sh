#!/bin/bash

sed -i 's/^Restart/#Restart/' /etc/systemd/system/ibmconnections.service

systemctl reenable /etc/systemd/system/ibmconnections.service