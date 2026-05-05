class openxpki::database (
  String  $db_name           = 'openxpki',
  String  $db_user           = lookup('openxpki::database::db_user', { default_value => 'openxpki' }),
  # No default value, APL (Automatic Parameter Lookup) provides these from hiera data.
  # This ensures that sensitive information like passwords is not hardcoded in the
  # manifest and can be securely managed through hiera.
  String  $db_password,
  String  $listen_address    = lookup('openxpki::database::db_host', { default_value => '127.0.0.1' }),
  Integer $db_port           = lookup('openxpki::database::db_port', { default_value => 5432 }),
  String  $cluster_version   = '15',   # Debian cluster layout version
  String  $pg_version        = '15',   # PostgreSQL major version
) {

  # --------------------------------------------------------------------------
  # PostgreSQL global settings (Debian layout)
  # --------------------------------------------------------------------------
  class { 'postgresql::globals':
    version => $pg_version,
    datadir => "/var/lib/postgresql/${cluster_version}/main",
    confdir => "/etc/postgresql/${cluster_version}/main",
  }

  # --------------------------------------------------------------------------
  # PostgreSQL server setup
  # --------------------------------------------------------------------------
  class { 'postgresql::server':
    listen_addresses => $listen_address,
    port             => $db_port,
  }

  # --------------------------------------------------------------------------
  # Create OpenXPKI database user
  # --------------------------------------------------------------------------
  postgresql::server::role { $db_user:
    password_hash => postgresql::postgresql_password($db_user, $db_password),
  }

  # --------------------------------------------------------------------------
  # Create OpenXPKI database
  # --------------------------------------------------------------------------
  postgresql::server::database { $db_name:
    owner   => $db_user,
    require => Postgresql::Server::Role[$db_user],
  }

}
