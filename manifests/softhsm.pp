class openxpki::softhsm (
  String[1] $slot               = lookup('openxpki::hsm::slot', { default_value => '0' }),
  String[1] $token_label        = lookup('openxpki::hsm::token_label', { default_value => 'OpenXPKI-CA' }),
  String[1] $ca_key_label       = lookup('openxpki::hsm::ca_key_label', { default_value => 'OpenXPKI-CA-Key' }),
  String[1] $ocsp_key_label     = lookup('openxpki::hsm::ocsp_key_label', { default_value => 'OpenXPKI-OCSP-Key' }),
  String[1] $pkcs11_module_path = lookup('openxpki::hsm::module_path', { default_value => '/usr/lib/softhsm/libsofthsm2.so' }),
  Sensitive[String[1]] $so_pin  = lookup('openxpki::hsm::so_pin'),
  Sensitive[String[1]] $user_pin = lookup('openxpki::hsm::user_pin'),
) {

  # Install SoftHSM2 package for PKCS#11 support.
  package { 'softhsm2':
    ensure => installed,
  }

  # Install OpenSC package for PKCS#11 tools and libraries (used by this
  # module for initialization of SoftHSM).
  package { 'opensc':
    ensure => installed,
  }

  # Initialize token only if it does not already exist
  exec { 'softhsm-init-token':
    command => "softhsm2-util --init-token --slot ${slot} --label ${token_label} --so-pin ${unwrap($so_pin)} --pin ${unwrap($user_pin)}",
    unless  => "softhsm2-util --show-slots | grep -q 'Label: *${token_label}'",
    path    => ['/usr/bin', '/usr/sbin'],
    require => Package['softhsm2'],
  }

  # Generate CA keypair if missing
  exec { 'softhsm-generate-ca-key':
    command => "pkcs11-tool --module ${pkcs11_module_path} --keypairgen --key-type rsa:4096 --label ${ca_key_label} --pin ${unwrap($user_pin)}",
    unless  => "pkcs11-tool --module ${pkcs11_module_path} --list-objects --pin ${unwrap($user_pin)} | grep -q 'label: *${ca_key_label}'",
    path    => ['/usr/bin', '/usr/sbin'],
    require => [Package['opensc'], Exec['softhsm-init-token']],
  }

  # Generate OCSP keypair if missing
  exec { 'softhsm-generate-ocsp-key':
    command => "pkcs11-tool --module ${pkcs11_module_path} --keypairgen --key-type rsa:4096 --label ${ocsp_key_label} --pin ${unwrap($user_pin)}",
    unless  => "pkcs11-tool --module ${pkcs11_module_path} --list-objects --pin ${unwrap($user_pin)} | grep -q 'label: *${ocsp_key_label}'",
    path    => ['/usr/bin', '/usr/sbin'],
    require => [Package['opensc'], Exec['softhsm-init-token']],
  }

}
