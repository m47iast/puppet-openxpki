# OpenXPKI module reference

This document is an initial reference for the classes and parameters that are implemented in this module.

## Class: `openxpki`

Main entry point. It validates the configured HSM backend and includes the required component classes.

### Parameters

- `hsm` (`String`): HSM backend to enable. Supported values: `softhsm`.
  - Default: `lookup('openxpki::hsm', { default_value => 'softhsm' })`

### Behavior

- Includes `openxpki::softhsm` when `hsm == 'softhsm'`
- Includes `openxpki::install`
- Includes `openxpki::config`

## Class: `openxpki::install`

Installs the OpenXPKI package repository and the required Debian packages.

### Resources managed

- APT signing key for the OpenXPKI package repository
- APT source for `https://packages.openxpki.org/v3/bookworm/`
- Package installation of:
  - `libopenxpki-perl`
  - `openxpki-cgi-session-driver`
  - `openxpki-i18n`

## Class: `openxpki::config`

Creates the OpenXPKI runtime configuration for database access, crypto backend settings, realm definitions, and WebUI defaults.

### Parameters

- `db_type` (`String`): backend type for the database section. Default: `PostgreSQL`
- `db_host` (`String`): database host. Default: `localhost`
- `db_port` (`Integer`): database port. Default: `5432`
- `db_name` (`String`): database name. Default: `openxpki`
- `db_user` (`String`): database user. Default: `undef`
- `db_password` (`String`): database password. Default: `undef`
- `db_session_password` (`String`): session DB password. Default: `undef`
- `wait_on_init_retry_count` (`Integer`): retry count for startup wait logic. Default: `undef`
- `log_level` (`Integer`): OpenXPKI log level. Default: `0`
- `ssl_bin_path` (`String`): path to the OpenSSL binary. Default: `/usr/bin/openssl`
- `hsm_module_path` (`String`): PKCS#11 module path. Default: `/usr/lib/softhsm/libsofthsm2.so`
- `hsm_slot` (`String`): HSM slot number. Default: `0`
- `hsm_token_label` (`String`): token label for the default key store. Default: `OpenXPKI-Default-Key`
- `hsm_ca_label` (`String`): CA key label. Default: `OpenXPKI-CA-Key`
- `hsm_ocsp_label` (`String`): OCSP key label. Default: `OpenXPKI-OCSP-Key`
- `hsm_pin` (`String`): user PIN. Default: `undef`
- `svault_key` (`String`): vault encryption key. Default: `undef`
- `realms` (`Hash[String, Hash[String, String]]`): realm definitions for the OpenXPKI WebUI.

### Files written

- `/etc/openxpki/config.d/system/database.yaml`
- `/etc/openxpki/config.d/system/crypto.yaml`
- `/etc/openxpki/config.d/system/realms.yaml`
- `/etc/openxpki/client.d/service/webui/default.yaml`

## Class: `openxpki::database`

Sets up the PostgreSQL role, database, and schema required by OpenXPKI.

### Parameters

- `db_name` (`String`): PostgreSQL database name. Default: `openxpki`
- `db_user` (`String`): DB user name. Default: `lookup('openxpki::database::db_user', { default_value => 'openxpki' })`
- `db_password` (`String`): Database password for the DB user. Required.
- `db_session_password` (`String`): Database password for the `openxpki_session` role. Required.
- `listen_address` (`String`): PostgreSQL listen address. Default: `127.0.0.1`
- `db_port` (`Integer`): PostgreSQL port. Default: `5432`
- `cluster_version` (`String`): Debian PostgreSQL cluster version. Default: `15`
- `pg_version` (`String`): PostgreSQL server version. Default: `15`

### Behavior

- Configures the PostgreSQL global settings for the Debian layout
- Creates the database role and database for OpenXPKI
- Copies `files/schema-psql.sql` into the documentation examples directory and applies it to the database
- Creates the `openxpki_session` role and grants `SELECT`, `INSERT`, `UPDATE`, and `DELETE` on `frontend_session`
- Installs the PostgreSQL DBI driver package `libdbd-pg-perl`

## Class: `openxpki::softhsm`

Initializes SoftHSM2 and creates the required PKCS#11 key pairs for OpenXPKI.

### Parameters

- `slot` (`String`): token slot to initialize. Default: `0`
- `token_label` (`String`): SoftHSM token label. Default: `OpenXPKI-CA`
- `ca_key_label` (`String`): CA signing key label. Default: `OpenXPKI-CA-Key`
- `ocsp_key_label` (`String`): OCSP signing key label. Default: `OpenXPKI-OCSP-Key`
- `pkcs11_module_path` (`String`): PKCS#11 provider library path. Default: `/usr/lib/softhsm/libsofthsm2.so`
- `so_pin` (`String`): Security officer PIN. Required.
- `user_pin` (`String`): User PIN. Required.

### Behavior

- Installs `softhsm2` and `opensc`
- Initializes a token in the selected slot
- Generates a CA key pair if it does not already exist
- Generates an OCSP key pair if it does not already exist

## Notes

- Sensitive values should be supplied through Hiera rather than directly in source files.
- This reference reflects the current implementation and is meant as a starting point for generated documentation.
