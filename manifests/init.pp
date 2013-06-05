class network {

    if $operatingsystem != "Ubuntu" or ($lsbmajdistrelease < 12 and $lsbdistrelease != "11.10") {
        # The 'source' directive in /etc/network/interfaces is a new feature
        fail "This module is only tested on Ubuntu 11.10+"
    }

    file { '/etc/network/interfaces':
        ensure  => present,
        mode    => '0440', owner => 'root', group => 'root',
        source  => 'puppet:///modules/network/interfaces',
    }

    file { '/etc/network/interfaces.d':
        ensure  => directory,
        mode    => '0550', owner => 'root', group => 'root',
    }

    package { 'iputils-arping': ensure => installed }

}
