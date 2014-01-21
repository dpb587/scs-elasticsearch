class scs (
    $version = '0.90.10',
    $cluster = 'default',
    $options = {},
) {
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

    exec {
        'elasticsearch' :
            command => "/usr/bin/wget -O- https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${version}.tar.gz | /bin/tar -xz && /bin/mv elasticsearch-* elasticsearch",
            cwd => '/scs/usr',
            require => [
                Package['wget'],
                File['/scs/usr'],
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
    }
}
