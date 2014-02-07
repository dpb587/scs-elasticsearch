class scs (
    $download_tgz = undef,
    $download_zip = undef,
    $download_tar = undef,
    $version = '1.0.0',
    $cluster = 'default',
    $es_env_opts = {},
    $es_run_args = [],
    $options = {},
) {
    if undef != $download_tar {
        $download_url = $download_tar
        $download_command = '/usr/bin/wget -qO- "$DOWNLOAD" | /bin/tar -x --strip-components 1'
    } elsif undef != $download_tgz {
        $download_url = $download_tgz
        $download_command = '/usr/bin/wget -qO- "$DOWNLOAD" | /bin/tar -xz --strip-components 1'
    } elsif undef != $download_zip {
        $download_url = $download_zip
        $download_command = '/usr/bin/wget "$DOWNLOAD" && /usr/bin/unzip -d .scstmp `basename "$DOWNLOAD"` && /bin/mv .scstmp/*/* ./ && /bin/rm -fr `basename "$DOWNLOAD"` .scstmp'
    } elsif undef != $version {
        $download_url = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${version}.tar.gz"
        $download_command = '/usr/bin/wget -qO- "$DOWNLOAD" | /bin/tar -xz --strip-components 1'
    }

    group {
        'scs' :
            ensure => present,
            gid => 1010,
            ;
    }

    user {
        'scs' :
            ensure => present,
            gid => 1010,
            shell => '/bin/false',
            uid => 1010,
            require => [
                Group['scs'],
            ],
            ;
    }

    file {
        '/scs/usr/elasticsearch' :
            ensure => directory,
            owner => 'scs',
            group => 'scs',
            mode => 0700,
            ;
    }

    exec {
        'elasticsearch' :
            command => $download_command,
            environment => [
                "DOWNLOAD=${download_url}",
            ],
            cwd => "/scs/usr/elasticsearch",
            creates => "/scs/usr/elasticsearch/bin/elasticsearch",
            require => [
                File["/scs/usr/elasticsearch"],
                Package['unzip'],
            ],
            ;
        'apt-update' :
            command => '/usr/bin/apt-get update',
            ;
        '/usr/bin/easy_install supervisor' :
            creates => '/usr/bin/supervisord',
            require => [
                Package['python-setuptools'],
            ],
            ;
    }

    file {
        "/scs/etc" :
            ensure => directory,
            ;
        "/scs/etc/supervisor.conf" :
            ensure => file,
            content => template('scs/supervisor/supervisor.conf.erb'),
            ;
        "/scs/etc/supervisor.d" :
            ensure => directory,
            ;
        "/scs/usr" :
            ensure => directory,
            ;
        "/scs/var" :
            ensure => directory,
            ;
        "/scs/var/log" :
            ensure => directory,
            ;
        "/scs/var/log/supervisord" :
            ensure => directory,
            ;
        "/scs/var/run" :
            ensure => directory,
            ;
        "/scs/var/run/supervisord" :
            ensure => directory,
            ;

        "/scs/etc/elasticsearch" :
            ensure => directory,
            ;
        "/scs/etc/elasticsearch/elasticsearch.yaml" :
            ensure => file,
            content => template('scs/elasticsearch/elasticsearch.yaml.erb'),
            ;
        "/scs/etc/supervisor.d/elasticsearch.conf" :
            ensure => file,
            content => template('scs/elasticsearch/supervisor.conf.erb'),
            ;
        "/scs/var/log/elasticsearch" :
            ensure => directory,
            owner => 'scs',
            group => 'scs',
            ;
        "/scs/var/run/elasticsearch" :
            ensure => directory,
            owner => 'scs',
            group => 'scs',
            ;
    }

    package {
        'openjdk-6-jre-headless' :
            ensure => installed,
            require => [
                Exec['apt-update'],
            ],
            ;
        'python-setuptools' :
            ensure => installed,
            require => [
                Exec['apt-update'],
            ],
            ;
        'wget' :
            ensure => installed,
            require => [
                Exec['apt-update'],
            ],
            ;
        'unzip' :
            ensure => installed,
            require => [
                Exec['apt-update'],
            ],
            ;
    }
}
