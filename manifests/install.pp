class openxpki::install {
  require apt

  apt::key { 'openxpki':
    source => 'https://packages.openxpki.org/v3/bookworm/Release.key',
    id     => '0A857FC5DFA8C6BE2A85A8D668ACB0D02C23C909',
  }

  apt::source { 'openxpki':
    location => 'https://packages.openxpki.org/v3/bookworm/',
    release  => 'bookworm',
    repos    => 'release',
    require  => Apt::Key['openxpki'],
  }

  package { ['libopenxpki-perl', 'openxpki-cgi-session-driver', 'openxpki-i18n', 'libdbd-pg-perl']:
    ensure  => installed,
    require => Apt::Source['openxpki'],
  }

}
