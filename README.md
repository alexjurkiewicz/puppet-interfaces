puppet-interfaces
=================

Per-interface network management for Ubuntu 11.10+.

Example:

    network::interface { "server01.company.com": interface => 'eth0', ensure => 'present', auto => true, type => 'dhcp', }

Requirements
============

Ubuntu 11.10+. If your interfaces(5) manpage mentions the 'source' parameter, you can use this module.

Sorry Debian users, this feature is not backported to you yet. Sorry RH users, your network configuration is different.

Usage
=====

There is one type: `network::interface`.

There are two non-obvious features you should be aware of:

* Every interface has pre-up and post-up checks added to ensure the IP is not already in use and ARP tables are updated. See the `standard_up_check` documentation below for further info.
* If `$vagrant` is true, nothing is done and a message is printed saying so. You can use this to ensure network changes are not rolled out when testing catalogs in [Vagrant](http://www.vagrantup.com/) (or a similar tool).

**Required Parameters:**

* `name`: Human readable identifier of this interface (eg hostname).
* `interface`: Interface name (eg eth0).
* `auto`: Bring up interface at boot (boolean).
* `type`: "static", "dhcp" or "bridge".

**Optional Parameters:**

* `ensure`: "present" or "absent" to create or remove the interface (default: none)
* `pre_up`: Array of commands that must complete successfully before the interface will be activated (default: none)
* `post_up`: Array of commands to run after bringing up the interface (default: none)
* `standard_up_checks`: Add the following configuration:
    `pre-up bash -c "! ping -c1 -w1 $ip"`
    `post-up arping -c 1 -A $ip`
    (default: 'yes')
    What this does: ifup'ing an interface will fail if the IP is already responding on the network. Once an interface is successfully brought up, a gratuitous ARP will be sent.
    The justification for this feature is as follows: it is better for an interface to not come up than to introduce an IP conflict. This param lets you disagree.

**Additional Parameters for Static Interfaces:**

* `ip`
* `netmask`: Optional, defaults to 255.255.255.255.
* `broadcast`: Optional, defaults to none.
* `gateway`: Optional, defaults to none.
* `bridge_ports`: Optional, defaults to none.
* `dns_servers`: Optional, defaults to none. (Note: this value should be a string, not array.)

EXAMPLES
========

DHCP interface:

    network::interface { "server01.company.com": interface => 'eth0', ensure => 'present', auto => true, type => 'dhcp', }

Static interface:

    network::interface { "server01-lan.company.com": interface => 'eth0', ensure => 'present', auto => true, ip => '1.2.3.4', netmask => '255.255.255.224', gateway => '5.6.7.8', }

Bridged interface:

  network::interface { "external interface for bridge": interface => 'eth0', ensure => 'present', auto => true, type => 'bridge', }
  network::interface { "internal interface for bridge": interface => 'br0', ensure => present, auto => true, ip => '1.2.3.4', netmask => '255.255.255.224', gateway => '5.6.7.8', bridge_ports => 'eth0', }

CREDITS
=======

Originally written by Alex Jurkiewicz at SiteMinder, 2013.
