class openxpki::install {

  # Install OpenXPKI official repository sources file
  file { '/etc/apt/sources.list.d/openxpki.sources':
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/openxpki/openxpki.sources',
    notify  => Exec['openxpki_apt_update'],
  }

  # Install OpenXPKI official repository GPG key
  package { 'gnupg':
    ensure => installed,
  }

  exec { 'install_openxpki_gpg_key':
    command => 'wget -q https://packages.openxpki.org/v3/bookworm/Release.key -O - | gpg -o /usr/share/keyrings/openxpki-archive-keyring.gpg --dearmor',
    path    => ['/usr/bin'],
    creates => '/usr/share/keyrings/openxpki-archive-keyring.gpg',
    notify  => Exec['openxpki_apt_update'],
  }

  # Update package lists after adding the new repository
  exec { 'openxpki_apt_update':
    command     => 'apt-get update',
    path        => ['/usr/bin'],
    refreshonly => true,
  }

  # Install OpenXPKI packages
  package { ['libopenxpki-perl', 'openxpki-cgi-session-driver', 'openxpki-i18n']:
    ensure  => installed,
    require => [
      File['/etc/apt/sources.list.d/openxpki.sources'],
      Exec['install_openxpki_gpg_key'],
      Exec['openxpki_apt_update']
    ],
  }

}
