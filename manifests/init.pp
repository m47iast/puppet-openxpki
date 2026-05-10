class openxpki (
  String $keystore_hsm = 'softhsm',  # Default to SoftHSM for PKCS#11 support, can be overridden to use a different HSM backend.
) {

  if $keystore_hsm == 'softhsm' {
    include openxpki::softhsm
  } else {
    error("Unsupported keystore HSM backend '${keystore_hsm}' specified. Supported options are: 'softhsm'.")
  }

}
