class openxpki::config (
  String $db_type     = lookup('openxpki::database::db_type', { default_value => 'PostgreSQL' }),
  String $db_host     = lookup('openxpki::database::db_host', { default_value => 'localhost' }),
  Integer $db_port    = lookup('openxpki::database::db_port', { default_value => 5432 }),
  String $db_name     = lookup('openxpki::database::db_name', { default_value => 'openxpki' }),
  String $db_user     = lookup('openxpki::database::db_user', { default_value => undef }),
  String $db_password = lookup('openxpki::database::db_password', { default_value => undef }),
  String $db_session_password = lookup('openxpki::database::db_session_password', { default_value => undef }),
  Integer $wait_on_init_retry_count = lookup('openxpki::database::wait_on_init_retry_count', { default_value => undef }),
  Integer $log_level  = lookup('openxpki::database::log_level', { default_value => 0 }),
) {

  # Install crtificate database configuration file
  file { '/etc/openxpki/config.d/system/database.yaml':
    ensure  => file,
    content => template('openxpki/config.d/system/database.yaml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  # Install WebUI service configuration file
  file { '/etc/openxpki/config.d/client.d/service/webui/default.yaml':
    ensure  => file,
    content => template('openxpki/config.d/client.d/service/webui/default.yaml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
