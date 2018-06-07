# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::roller::setup($home, $username, $group) {
    anchor {
        'users::roller::setup::begin': ;
        'users::roller::setup::end': ;
    }

    Anchor['users::roller::setup::begin'] ->
    ssh::userconfig {
        $username:
            home                          => $home,
            group                         => $group,
            authorized_keys               => 'roller_ssh_pub_key',
            authorized_keys_allows_extras => false,
            config                        => template('users/roller-ssh-config.erb');
    } -> Anchor['users::roller::setup::end']

    case $::operatingsystem {
        # Roller needs ssh for reboot on macs only
        Darwin: {
            include sudoers
            include sudoers::settings
            include users::roller

            sudoers::custom {
                'roller-reboot':
                    user    => $users::roller::username,
                    runas   => 'root',
                    command => "$sudoers::settings::rebootpath, /usr/sbin/bless";
            }
        }
    }

    file {
        "${home}/.ssh/allowed_commands.sh":
            mode    => filemode(0700),
            owner   => $username,
            group   => $group,
            content => template('users/roller-allowed_commands.sh.erb');
    }
}
