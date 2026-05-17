class openxpki::softhsm (
  String $slot               = lookup('openxpki::hsm::slot',           { default_value => '0' }),
  String $token_label        = lookup('openxpki::hsm::token_label',    { default_value => 'OpenXPKI-CA' }),
  String $ca_key_label       = lookup('openxpki::hsm::ca_key_label',   { default_value => 'OpenXPKI-CA-Key' }),
  String $ocsp_key_label     = lookup('openxpki::hsm::ocsp_key_label', { default_value => 'OpenXPKI-OCSP-Key' }),
  String $pkcs11_module_path = lookup('openxpki::hsm::module_path',    { default_value => '/usr/lib/softhsm/libsofthsm2.so' }),
  # No default value, to ensure that sensitive information like passwords are
  # not hardcoded in the manifest and can be securely managed through hiera.
  String $so_pin             = lookup('openxpki::hsm::so_pin'),
  String $user_pin           = lookup('openxpki::hsm::user_pin'),
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
    command => "softhsm2-util --init-token --slot ${slot} --label ${token_label} --so-pin ${so_pin} --pin ${user_pin}",
    unless  => "softhsm2-util --show-slots | grep -q 'Label: *${token_label}'",
    path    => ['/usr/bin', '/usr/sbin'],
    require => Package['softhsm2'],
  }

  # Generate CA keypair if missing
  exec { 'softhsm-generate-ca-key':
    command => "pkcs11-tool --module ${pkcs11_module_path} --keypairgen --key-type rsa:4096 --label ${ca_key_label} --pin ${user_pin}",
    unless  => "pkcs11-tool --module ${pkcs11_module_path} --list-objects --pin ${user_pin} | grep -q 'label: *${ca_key_label}'",
    path    => ['/usr/bin', '/usr/sbin'],
    require => [Package['opensc'], Exec['softhsm-init-token']],
  }

  # Generate OCSP keypair if missing
  exec { 'softhsm-generate-ocsp-key':
    command => "pkcs11-tool --module ${pkcs11_module_path} --keypairgen --key-type rsa:4096 --label ${ocsp_key_label} --pin ${user_pin}",
    unless  => "pkcs11-tool --module ${pkcs11_module_path} --list-objects --pin ${user_pin} | grep -q 'label: *${ocsp_key_label}'",
    path    => ['/usr/bin', '/usr/sbin'],
    require => [Package['opensc'], Exec['softhsm-init-token']],
  }

}
