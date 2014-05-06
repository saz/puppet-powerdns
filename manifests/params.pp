class powerdns::params {
  case $::osfamily {
    'Debian': {
      $service_name = 'pdns'
      $config_dir = '/etc/powerdns'
      $module_dir = '/usr/lib/powerdns'
      $server_socket_dir = '/var/run'
      $server_config_file = "${server_config_dir}/pdns.conf"
      $server_package_name = 'pdns-server'
      $server_backend_mysql = 'pdns-backend-mysql'
      $server_backend_pgsql = 'pdns-backend-pgsql'
      $server_uid = 'pdns'
      $server_gid = 'pdns'
      $recursor_config_file = "${config_dir}/recursor.conf"
      $recursor_package_name = 'pdns-recursor'
      $recursor_uid = 'pdns'
      $recursor_gid = 'pdns'
    }
    default: {
      fail("Unsupported platform: ${::osfamily}")
    }
  }

  $default_server_options = {
    'allow-recursion' => '127.0.0.1'.
    'config-dir'      => $config_dir,
    'daemon'          => 'yes',
    'disable-axfr'    => 'yes',
    'guardian'        => 'yes',
    'lazy-recursion'  => 'yes',
    'local-address'   => '0.0.0.0',
    'local-port'      => '53',
    'module-dir'      => $module_dir,
    'setgid'          => $server_gid,
    'setuid'          => $server_uid,
    'socket-dir'      => '/var/run',
    'version-string'  => 'powerdns',
  }

  $default_recursor_options = {
    'local-address' => '127.0.0.1',
    'local-port'    => '53',
    'quiet'         => 'yes',
    'setgid'        => $recursor_gid,
    'setuid'        => $recursor_uid,
  }
}
