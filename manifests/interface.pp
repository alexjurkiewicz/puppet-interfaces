define network::interface (
    $interface,$auto,$ensure,
    $type = 'static',
    $ip = undef,
    $netmask = undef,
    $broadcast = undef,
    $gateway = undef,
    $dns_servers = undef,
    $dns_search = undef,
    $pre_up = [],$post_up = [],
    $standard_up_checks = true,
    $bridge_ports = undef,
    ) {

    # If we're in vagrant do nothing
    if $vagrant == 'true' {
        notice ("Not deploying prod IPs in Vagrant")

    } else {
        # Validate params
        if ! ($type in [ "static", "dhcp", "bridge" ]) {
            fail "type must be static, dhcp or bridge"
        }
        if $type == 'static' and ( $ip == undef or $netmask == undef ) {
            fail "static interfaces must have ip and netmask specified"
        }
        if ( $type in [ "dhcp", "bridge" ] ) and ( $ip != undef or $netmask != undef or $broadcast != undef or $gateway != undef ) {
            fail "dhcp/bridge interfaces can't have ip, netmask, broadcast or gateway specified"
        }
        if $type == "bridge" and ( $dns_servers != undef or $dns_search != undef) {
            fail "bridge interfaces can't have dns_servers or dns_search specified"
        }
    
        include network
    
        if $standard_up_checks == true {
            $real_pre_up  = [ $pre_up, "bash -c '! ping -c1 -w1 $ip'" ]
            $real_post_up = [ $post_up, "arping -c 1 -A $ip" ]
        } else {
            $real_pre_up  = $pre_up
            $real_post_up = $post_up
        }
    
        case $ensure {
            "present": {
                file { "/etc/network/interfaces.d/${interface}.cfg":
                    ensure  => present,
                    content => template("network/interface.erb"),
                    owner   => root, group => root, mode => 0444,
                }
            }
            "absent": {
                file { "/etc/network/interfaces.d/${interface}.cfg":
                    ensure  => absent,
                }
            }
            default: {
                fail "\$ensure must be 'present' or 'absent' for network::interface"
            }
        }
    }
}
