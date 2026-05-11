class openxpki::install {
  require apt

  apt::key { 'openxpki':
    source => 'https://packages.openxpki.org/v3/bookworm/Release.key',
  }

  apt::source { 'openxpki':
    location => 'https://packages.openxpki.org/v3/bookworm/',
    release  => 'bookworm',
    repos    => 'release',
    require  => Apt::Key['openxpki'],
  }

  package { ['libopenxpki-perl', 'openxpki-cgi-session-driver', 'openxpki-i18n']:
    ensure  => installed,
    require => Apt::Source['openxpki'],
  }

}
