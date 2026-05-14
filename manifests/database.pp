class openxpki::database (
  String  $db_name           = 'openxpki',
  String  $db_user           = lookup('openxpki::database::db_user', { default_value => 'openxpki' }),
  # No default value, APL (Automatic Parameter Lookup) provides these from hiera data.
  # This ensures that sensitive information like passwords is not hardcoded in the
  # manifest and can be securely managed through hiera.
  String  $db_password,
  String  $db_session_password,
  String  $listen_address    = lookup('openxpki::database::db_host', { default_value => '127.0.0.1' }),
  Integer $db_port           = lookup('openxpki::database::db_port', { default_value => 5432 }),
  String  $cluster_version   = '15',   # Debian cluster layout version
  String  $pg_version        = '15',   # PostgreSQL major version
) {

  # PostgreSQL global settings (Debian layout)
  class { 'postgresql::globals':
    version => $pg_version,
    datadir => "/var/lib/postgresql/${cluster_version}/main",
    confdir => "/etc/postgresql/${cluster_version}/main",
  }

  # PostgreSQL server setup
  class { 'postgresql::server':
    listen_addresses => $listen_address,
    port             => $db_port,
  }

  # Create OpenXPKI database user
  postgresql::server::role { $db_user:
    password_hash => postgresql::postgresql_password($db_user, $db_password),
  }

  # Create OpenXPKI database
  postgresql::server::database { $db_name:
    owner   => $db_user,
    require => Postgresql::Server::Role[$db_user],
  }

  # Install OpenXPKI PostgreSQL schema SQL file and apply to the database
  # Mimick path and permissions of openxpki.org Debian package sample SQL
  # schema.
  file { ['/usr/share/doc/libopenxpki-perl', '/usr/share/doc/libopenxpki-perl/examples']:
    ensure => directory,
    mode   => '0644',
  }
  file { '/usr/share/doc/libopenxpki-perl/examples/schema-psql.sql':
    ensure => file,
    source => 'puppet:///modules/openxpki/schema-psql.sql',
  }
  exec { "Apply OpenXPKI schema to ${db_name}":
    command   => "psql -d ${db_name} -f /usr/share/doc/libopenxpki-perl/examples/schema-psql.sql",
    unless    => "psql -d ${db_name} -c \"SELECT 1 FROM information_schema.tables WHERE table_name = 'certificate'\" | grep -q 1",
    path      => ['/usr/bin'],
    user      => 'postgres',
    group     => 'postgres',
    require   => [Postgresql::Server::Database[$db_name], File['/usr/share/doc/libopenxpki-perl/examples/schema-psql.sql']],
  }

  # Create role and apply grants for OpenXPKI session management
  postgresql::server::role { 'openxpki_session':
    password_hash => postgresql::postgresql_password('openxpki_session', $db_session_password),
  }
  ['SELECT','INSERT','UPDATE','DELETE'].each |$priv| {
    postgresql::server::table_grant { "Grant ${priv} to openxpki_session":
      db         => $db_name,
      table      => 'frontend_session',
      privilege  => $priv,
      role       => 'openxpki_session',
    }
  }

  # Install Perl DBI driver for PostgreSQL (for OpenXPKI to connect to the database).
  package { 'libdbd-pg-perl' :
    ensure  => installed,
  }

}
