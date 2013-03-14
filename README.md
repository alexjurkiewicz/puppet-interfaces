puppet-interfaces
=================

Per-interface network management for Puppet.

Requirements
============

Ubuntu 11.10+ or equivalent Debian. If your `interfaces(5)` manpage mentions the 'source' parameter, you can use this module.

Usage
=====

This module provides one type: `network::interface`.

There are two non-obvious features you should be aware of:

* Every interface has pre-up and post-up checks added to ensure the IP is not already in use and ARP tables are updated. See the `standard_up_check` documentation below for further info.
* If `$vagrant` is true, nothing is done and a message is printed saying so. We use Vagrant to test as much of our Puppet runs as possible on local boxes before committing changes, for obvious reasons network changes cannot be tested like this.

**Required Parameters:**

* `name` Human readable identifier of this interface (eg hostname).
* `interface` Interface name (eg eth0).
* `ensure` "present" or "absent" to create or remove the interface.
* `auto` Bring up interface at boot (boolean).
* `type` "static", "dhcp" or "bridge".

**Optional Parameters:**

* `pre_up` Array of commands that must complete successfully before the interface will be activated (default: none)
* `post_up` Array of commands to run after bringing up the interface (default: none)
* `standard_up_checks` For every interface, this module adds the following configuration:

        pre-up bash -c "! ping -c1 -w1 $ip"`
        post-up arping -c 1 -A $ip`
    
    Setting this parameter to "false" disables this functionality. The justification for this feature is as follows: it is better for an interface to not come up than to introduce an IP address conflict on the network. This param lets you disagree. (Default: true)

**Additional Parameters for Static Interfaces:**

* `ip`
* `netmask`
* `broadcast` (Default: none)
* `gateway` (Default: none)
* `bridge_ports` (Default: none)
* `dns_servers` (Default: none) (Note: this value should be a string, not array.)

EXAMPLES
========

DHCP interface:

    network::interface { "server01.company.com":
        interface => 'eth0',
        ensure => 'present',
        auto => true,
        type => 'dhcp',
    }

Static interface:

    network::interface { "server01-lan.company.com":
        interface => 'eth0',
        ensure => 'present',
        auto => true,
        ip => '1.2.3.4',
        netmask => '255.255.255.224',
        gateway => '5.6.7.8',
    }

Bridged interface:

    network::interface { "external interface for bridge":
        interface => 'eth0',
        ensure => 'present',
        auto => true,
        type => 'bridge',
    }
    network::interface { "internal interface for bridge": interface => 'br0', ensure => present, auto => true, ip => '1.2.3.4', netmask => '255.255.255.224', gateway => '5.6.7.8', bridge_ports => 'eth0', }
