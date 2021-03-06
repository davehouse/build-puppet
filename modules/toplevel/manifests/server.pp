# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Basically anything that is *not* a slave is a subclass of this class.  These
# are machines that are generally up for a long time and expected to be online.

class toplevel::server inherits toplevel::base {
    include puppet::periodic
    include ntp::daemon
    include smarthost
    include cron
    include disableservices::server
    include nrpe
    include nrpe::check::puppet_agent
    include nrpe::check::ntp_time
    include nrpe::check::ntp_peer
    include nrpe::check::procs_regex
    include nrpe::check::child_procs_regex
    include nrpe::check::swap
    include nrpe::check::ide_smart
    include nrpe::check::puppet_freshness
    include packages::strace
    include packages::netcat
    include users::people
    include ::config
    include packages::security_updates
    include packages::security_updates_1433165
    include python::system_pip_conf

    # auditd only runs on CentOS at the moment
    case $::operatingsystem {
        'CentOS': {
            class {
                'auditd':
                    host_type => 'server';
            }
            include packages::procmail
            include packages::nslookup
            include packages::nss_tools
            include packages::snmp
            include packages::wget
            include packages::mysql_devel
            include packages::subversion
        }
    }
}
