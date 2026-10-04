class openxpki::config (
  String  $db_type         = lookup('openxpki::database::db_type',   { default_value => 'PostgreSQL' }),
  String  $db_host         = lookup('openxpki::database::db_host',   { default_value => 'localhost' }),
  Integer $db_port         = lookup('openxpki::database::db_port',   { default_value => 5432 }),
  String  $db_name         = lookup('openxpki::database::db_name',   { default_value => 'openxpki' }),
  String  $db_user         = lookup('openxpki::database::db_user',   { default_value => undef }),
  String  $db_password     = lookup('openxpki::database::db_password', { default_value => undef }),
  String  $db_session_password = lookup('openxpki::database::db_session_password', { default_value => undef }),
  Integer $wait_on_init_retry_count = lookup('openxpki::database::wait_on_init_retry_count', { default_value => undef }),
  Integer $log_level       = lookup('openxpki::database::log_level', { default_value => 0 }),
  Strign  $ssl_bin_path    = lookup('openxpki::ssl::bin_path', { default_value => '/usr/bin/openssl' }),
  String  $hsm_module_path = lookup('openxpki::hsm::module_path',    { default_value => '/usr/lib/softhsm/libsofthsm2.so' }),
  String  $hsm_slot        = lookup('openxpki::hsm::slot',           { default_value => '0' }),
  String  $hsm_token_label = lookup('openxpki::hsm::token_label',    { default_value => 'OpenXPKI-Default-Key' }),
  String  $hsm_ca_label    = lookup('openxpki::hsm::ca_key_label',   { default_value => 'OpenXPKI-CA-Key' }),
  String  $hsm_ocsp_label  = lookup('openxpki::hsm::ocsp_key_label', { default_value => 'OpenXPKI-OCSP-Key' }),
  String  $hsm_pin         = lookup('openxpki::hsm::user_pin',       { default_value => undef }),
  String  $svault_key      = lookup('openxpki::hsm::svault_key',     { default_value => undef }),
  Hash[String, Hash[String, String]] $realms = lookup(
    'openxpki::realms', 
    { 
      default_value => {
        'default-realm' => {
          'label'       => "Default Certificate Authority",
          'baseurl'     => "https://localhost/webui/hlcs-ca/",
          'description' => "Default CA Realm",
          'color'       => "#EFD"
        },
      }
    }
  ),
) {

  # Install crtificate database configuration file
  file { '/etc/openxpki/config.d/system/database.yaml':
    ensure  => file,
    content => template('openxpki/config.d/system/database.yaml.erb'),
    owner   => 'openxpki',
    group   => 'root',
    mode    => '0640',
  }

  # Install crypto configuration file
  file { '/etc/openxpki/config.d/system/crypto.yaml':
    ensure  => file,
    content => template('openxpki/config.d/system/crypto.yaml.erb'),
    owner   => 'openxpki',
    group   => 'root',
    mode    => '0640',
  }

  # Install realms configuration file
  file { '/etc/openxpki/config.d/system/realms.yaml':
    ensure  => file,
    content => template('openxpki/config.d/system/realms.yaml.erb'),
    owner   => 'openxpki',
    group   => 'root',
    mode    => '0640',
  }

  # Install WebUI service configuration file
  file { '/etc/openxpki/client.d/service/webui/default.yaml':
    ensure  => file,
    content => template('openxpki/client.d/service/webui/default.yaml.erb'),
    owner   => 'openxpki',
    group   => 'root',
    mode    => '0644',
  }
}
