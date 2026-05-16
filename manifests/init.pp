class openxpki (
  String $hsm = lookup('openxpki::hsm', { default_value => 'softhsm' }),
) {

  if $hsm == 'softhsm' {
    include openxpki::softhsm
  } else {
    error("Unsupported keystore HSM backend '${hsm}' specified. Supported options are: 'softhsm'.")
  }

  include openxpki::install
  include openxpki::config

}
