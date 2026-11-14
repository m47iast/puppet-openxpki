# OpenXPKI Puppet module

This module installs and configures a Debian-based OpenXPKI deployment with a PostgreSQL backend and a SoftHSM2 PKCS#11 token. It is intentionally opinionated for the package layout used by the upstream OpenXPKI Debian repository and writes the configuration files under `/etc/openxpki`.

## Features

- Installs the OpenXPKI Debian package set from the upstream APT repository
- Configures PostgreSQL for the OpenXPKI database and session driver
- Installs and initializes SoftHSM2 and PKCS#11 key material
- Writes the OpenXPKI system configuration files for database, crypto, realms, and WebUI
- Supports Hiera-based secrets and environment-specific tuning

## Supported configuration

The module currently supports:

- `openxpki` main class
- `openxpki::install`
- `openxpki::config`
- `openxpki::database`
- `openxpki::softhsm`

The default HSM backend is `softhsm` and the module validates that value before continuing.

## Requirements

- Puppet 7 or later
- Debian 12 (Bookworm) or a compatible Debian-derived system
- `puppetlabs/apt`
- `puppetlabs/postgresql`

## Example usage

```puppet
class { 'openxpki':
  hsm => 'softhsm',
}

class { 'openxpki::database':
  db_name            => 'openxpki',
  db_user            => 'openxpki',
  db_password        => lookup('openxpki::database::db_password'),
  db_session_password => lookup('openxpki::database::db_session_password'),
}
```

This module is designed to be driven by Hiera for sensitive values such as database credentials, HSM pins, and vault keys.

## Hiera example

```yaml
openxpki::hsm: 'softhsm'

openxpki::database::db_name: 'openxpki'
openxpki::database::db_user: 'openxpki'
openxpki::database::db_password: '%{lookup("openxpki::secrets::db_password")}'
openxpki::database::db_session_password: '%{lookup("openxpki::secrets::db_session_password")}'

openxpki::hsm::so_pin: '0000'
openxpki::hsm::user_pin: '123456'
openxpki::hsm::svault_key: '0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF'
```

## Files managed by the module

The configuration class writes the following files:

- `/etc/openxpki/config.d/system/database.yaml`
- `/etc/openxpki/config.d/system/crypto.yaml`
- `/etc/openxpki/config.d/system/realms.yaml`
- `/etc/openxpki/client.d/service/webui/default.yaml`

## Notes

- This module is an initial implementation and is intentionally focused on a minimal, working OpenXPKI deployment.
- Secret values should not be hardcoded in manifests; prefer Hiera, eyaml, or a secret backend.
- The SQL schema file is copied from the module under `files/schema-psql.sql` and applied to the PostgreSQL database.

## License

This project is licensed under the Apache License, Version 2.0.
