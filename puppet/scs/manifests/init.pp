class scs (
    $download_tgz = undef,
    $download_zip = undef,
    $download_tar = undef,
    $version = '1.0.1',
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

    file {
        '/usr/bin/scs-runtime-hook-start' :
            ensure => file,
            source => 'puppet:///modules/scs/scs-runtime-hook-start',
            owner => 'root',
            group => 'root',
            mode => 0755,
            ;
        '/usr/local/elasticsearch' :
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
            cwd => "/usr/local/elasticsearch",
            creates => "/usr/local/elasticsearch/bin/elasticsearch",
            require => [
                File["/usr/local/elasticsearch"],
                Package['unzip'],
            ],
            ;
        '/usr/bin/easy_install supervisor' :
            creates => '/usr/bin/supervisord',
            require => [
                Package['python-setuptools'],
            ],
            ;
    }

    file {
        "/etc/elasticsearch" :
            ensure => directory,
            ;
        "/etc/elasticsearch/elasticsearch.yaml" :
            ensure => file,
            content => template('scs/elasticsearch/elasticsearch.yaml.erb'),
            ;
        "/etc/supervisor.d/elasticsearch.conf" :
            ensure => file,
            content => template('scs/elasticsearch/supervisor.conf.erb'),
            ;
        "/var/log/elasticsearch" :
            ensure => directory,
            owner => 'scs',
            group => 'scs',
            ;
        "/var/run/elasticsearch" :
            ensure => directory,
            owner => 'scs',
            group => 'scs',
            ;
    }

    package {
        'openjdk-6-jre-headless' :
            ensure => installed,
            ;
        'python-setuptools' :
            ensure => installed,
            ;
        'wget' :
            ensure => installed,
            ;
        'unzip' :
            ensure => installed,
            ;
    }
}
