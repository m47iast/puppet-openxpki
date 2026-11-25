class openxpki::config (
  String  $db_type         = lookup('openxpki::database::db_type',   { default_value => 'PostgreSQL' }),
  String[1] $db_host       = lookup('openxpki::database::db_host', { default_value => 'localhost' }),
  Integer[1, 65535] $db_port = lookup('openxpki::database::db_port', { default_value => 5432 }),
  String[1] $db_name       = lookup('openxpki::database::db_name', { default_value => 'openxpki' }),
  String[1] $db_session_user = lookup('openxpki::database::db_session_user', { default_value => 'openxpki_session' }),
  String[1] $db_user       = lookup('openxpki::database::db_user', { default_value => 'openxpki' }),
  Sensitive[String[1]] $db_password = lookup('openxpki::database::db_password'),
  Sensitive[String[1]] $db_session_password = lookup('openxpki::database::db_session_password'),
  Optional[Integer[1]] $wait_on_init_retry_count = lookup('openxpki::database::wait_on_init_retry_count', { default_value => undef }),
  Integer $log_level       = lookup('openxpki::database::log_level', { default_value => 0 }),
  String  $ssl_bin_path    = lookup('openxpki::ssl::bin_path', { default_value => '/usr/bin/openssl' }),
  String[1] $hsm_module_path = lookup('openxpki::hsm::module_path', { default_value => '/usr/lib/softhsm/libsofthsm2.so' }),
  String[1] $hsm_slot        = lookup('openxpki::hsm::slot', { default_value => '0' }),
  String[1] $hsm_token_label = lookup('openxpki::hsm::token_label', { default_value => 'OpenXPKI-Default-Key' }),
  String[1] $hsm_ca_label    = lookup('openxpki::hsm::ca_key_label', { default_value => 'OpenXPKI-CA-Key' }),
  String[1] $hsm_ocsp_label  = lookup('openxpki::hsm::ocsp_key_label', { default_value => 'OpenXPKI-OCSP-Key' }),
  Sensitive[String[1]] $hsm_pin = lookup('openxpki::hsm::user_pin'),
  Sensitive[Pattern[/\A[0-9A-Fa-f]{64}\z/]] $svault_key = lookup('openxpki::hsm::svault_key'),
  Sensitive[String[1]] $crypto_default_secret = lookup('openxpki::crypto::default_secret'),
  Sensitive[String[1]] $crypto_ratoken_secret = lookup('openxpki::crypto::ratoken_secret'),
  Sensitive[String[1]] $webui_cookie_key = lookup('openxpki::webui::cookie_key'),
  Hash[String, Hash[String, String]] $realms = lookup(
    'openxpki::realms', 
    { 
      default_value => {
        'default-realm' => {
          'label'       => "Default Certificate Authority",
          'baseurl'     => "https://localhost/webui/default/",
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
    content => epp('openxpki/config.d/system/database.yaml.epp', {
      'db_type'                  => $db_type,
      'db_name'                  => $db_name,
      'db_host'                  => $db_host,
      'db_port'                  => $db_port,
      'db_user'                  => $db_user,
      'db_password'              => $db_password,
      'wait_on_init_retry_count' => $wait_on_init_retry_count,
    }),
    owner   => 'openxpki',
    group   => 'root',
    mode    => '0640',
  }

  # Install crypto configuration file
  file { '/etc/openxpki/config.d/system/crypto.yaml':
    ensure  => file,
    content => epp('openxpki/config.d/system/crypto.yaml.epp', {
      'ssl_bin_path'    => $ssl_bin_path,
      'hsm_module_path' => $hsm_module_path,
      'hsm_slot'        => $hsm_slot,
      'hsm_token_label' => $hsm_token_label,
      'hsm_ca_label'    => $hsm_ca_label,
      'hsm_ocsp_label'  => $hsm_ocsp_label,
      'hsm_pin'         => $hsm_pin,
      'svault_key'      => $svault_key,
      'crypto_default_secret' => $crypto_default_secret,
      'crypto_ratoken_secret' => $crypto_ratoken_secret,
    }),
    owner   => 'openxpki',
    group   => 'root',
    mode    => '0640',
  }

  # Install realms configuration file
  file { '/etc/openxpki/config.d/system/realms.yaml':
    ensure  => file,
    content => epp('openxpki/config.d/system/realms.yaml.epp', {
      'realms' => $realms,
    }),
    owner   => 'openxpki',
    group   => 'root',
    mode    => '0640',
  }

  # Install WebUI service configuration file
  file { '/etc/openxpki/client.d/service/webui/default.yaml':
    ensure  => file,
    content => epp('openxpki/client.d/service/webui/default.yaml.epp', {
      'db_name'             => $db_name,
      'db_host'             => $db_host,
      'db_session_user'     => $db_session_user,
      'db_session_password' => $db_session_password,
      'webui_cookie_key'    => $webui_cookie_key,
    }),
    owner   => 'openxpki',
    group   => 'root',
    mode    => '0640',
  }
}
