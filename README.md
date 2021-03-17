# systemd-mac-address-monitor-dbus

Sends `ip monitor neigh dev eth0` MAC address discovery data to Systemd D-Bus for your custom SystemD D-Bus service(s). It's intended to run on firewall or router machine.

# Why?

For example:

* Automatically add new firewall rules
* Automatic inventory discovery
* Find intruders
* Configure per-mac address VLANs to your switch(es)
* Gather statistics when device(s) are (dis)connected to/from a network
* Send MAC address to a database
* Send alert(s) when MAC address X is not seen for a while
* etc...
 
