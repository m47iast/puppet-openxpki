class openxpki (
  String  $hsm             = lookup('openxpki::hsm', { default_value => 'softhsm' }),
  Boolean $manage_database = lookup('openxpki::manage_database', { default_value => true }),
) {

  if $hsm == 'softhsm' {
    contain openxpki::softhsm
  } else {
    error("Unsupported keystore HSM backend '${hsm}' specified. Supported options are: 'softhsm'.")
  }

  contain openxpki::install
  contain openxpki::config

  if $manage_database {
    contain openxpki::database
    Class['openxpki::install'] -> Class['openxpki::database'] -> Class['openxpki::config']
  } else {
    Class['openxpki::install'] -> Class['openxpki::config']
  }

  Class['openxpki::softhsm'] -> Class['openxpki::config']

}
