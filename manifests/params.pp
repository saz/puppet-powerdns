class powerdns::params {
  case $::osfamily {
    'Debian': {
      $service_name = 'pdns'
      $config_dir = '/etc/powerdns'
      $server_config_file = "${server_config_dir}/pdns.conf"
      $server_package_name = 'pdns-server'
      $server_backend_mysql = 'pdns-backend-mysql'
      $server_backend_pgsql = 'pdns-backend-pgsql'
      $recursor_config_file = "${config_dir}/recursor.conf"
      $recursor_package_name = 'pdns-recursor'
    }
    default: {
      fail("Unsupported platform: ${::osfamily}")
    }
  }
}
