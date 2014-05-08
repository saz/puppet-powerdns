# == Class: powerdns
#
# Full description of class powerdns here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { powerdns:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class powerdns (
  $ensure = 'present',
  $enable_recursor = false,
  $recursor_options = {},
  $server_options = {},
  $package_ensure = 'installed',
  $config_dir = $::powerdns::params::config_dir,
  $server_service_name = $::powerdns::params::server_service_name,
  $server_service_enable = true,
  $server_service_ensure = 'running',
  $server_config_file = $::powerdns::params::server_config_file,
  $server_package_name = $::powerdns::params::server_package_name,
  $server_backend_mysql = false,
  $server_backend_pgsql = false,
  $recursor_service_name = $::powerdns::params::recursor_service_name,
  $recursor_service_enable = true,
  $recursor_service_ensure = 'running',
  $recursor_config_file = $::powerdns::params::recursor_config_file,
  $recursor_package_name = $::powerdns::params::recursor_package_name,
  $purge_config_dir = true,
) inherits powerdns::params {

  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure.
  Allowed values are 'present' and 'absent'.")

  validate_re($server_service_ensure, '^(running|stopped)$',
  "${server_service_ensure} is not supported for server_service_ensure.
  Allowed values are 'running' and 'stopped'.")

  validate_re($recursor_service_ensure, '^(running|stopped)$',
  "${recursor_service_ensure} is not supported for recursor_service_ensure.
  Allowed values are 'running' and 'stopped'.")

  validate_bool($server_service_enable)
  validate_hash($server_options)
  validate_bool($server_backend_mysql)
  validate_bool($server_backend_pgsql)
  validate_hash($recursor_options)
  validate_bool($recursor_service_enable)

  $server_options_merged = merge(
    $powerdns::params::default_server_options, $server_options
  )

  $recursor_options_merged = merge(
    $powerdns::params::default_recursor_options, $recursor_options
  )

  case $ensure {
    present: {
      $package_ensure_real = $package_ensure
      $service_ensure_real = $service_ensure
      $file_ensure = 'file'
      $directory_ensure = 'directory'
    }
    absent: {
      $package_ensure_real = 'absent'
      $service_ensure_real = 'stopped'
      $file_ensure = 'file'
      $directory_ensure = 'absent'
    }
  }

  package { $server_package_name:
    ensure => $package_ensure_real,
  }

  if $server_backend_mysql {
    package { $powerdns::params::server_backend_mysql:
      ensure => $package_ensure_real,
    }
  }

  if $server_backend_pgsql {
    package { $powerdns::params::server_backend_pgsql:
      ensure => $package_ensure_real,
    }
  }

  file { $config_dir:
    ensure  => $directory_ensure,
    owner   => 0,
    group   => 0,
    mode    => '0755',
    purge   => $purge_config_dir,
    recurse => true,
    force   => true,
    require => Package[$server_package_name],
  }

  file { $server_config_file:
    ensure  => $file_ensure,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template("${module_name}/pdns.conf.erb"),
    notify  => Service[$server_service_name],
    require => File[$config_dir],
  }

  service { $server_service_name:
    ensure     => $server_service_ensure,
    enable     => $server_service_enable,
    hasstatus  => true,
    hasrestart => true,
    require    => File[$server_config_file],
  }

  if $enable_recursor {
    if $recursor_package_name {
      package { $recursor_package_name:
        ensure  => $package_ensure_real,
        require => File[$config_dir],
      }
    }

    file { $recursor_config_file:
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0644',
      content => template("${module_name}/recursor.conf.erb"),
      notify  => Service[$recursor_service_name],
      require => Package[$recursor_package_name],
    }

    service { $recursor_service_name:
      ensure     => $recursor_service_ensure,
      enable     => $recursor_service_enable,
      hasstatus  => false,
      hasrestart => true,
      require    => File[$recursor_config_file],
    }
  }
}
