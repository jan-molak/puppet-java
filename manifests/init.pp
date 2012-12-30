# Class: java
#
# Parameters:
#   The parameters listed here are not required in general and were
#     added for use cases related to development environments.
#   with_maven - whether or not install maven (default: false)
#   with_ant   - whether or not install ant (default: false)
# Actions:
#
# Requires:
#   puppetlabs/apt
#
# Sample Usage:
#  class { 'java': }

class java(
  $with_maven = false,
  $with_ant   = false
) {
  include apt

  if $with_maven == true {
    package { 'maven':
      require => Package['oracle-java6-installer'],
      ensure  => latest;
    }
  }

  if $with_ant == true {
    package { 'ant':
      require => Package['oracle-java6-installer'],
      ensure  => latest;
    }
  }

  package { 'oracle-java6-installer':
    require      => [ Apt::Ppa['ppa:webupd8team/java'], File["/var/cache/debconf/java6.seeds"] ],
    responsefile => "/var/cache/debconf/java6.seeds",
    ensure       => latest;
  }

  apt::ppa { 'ppa:webupd8team/java': }

  file { "/var/cache/debconf/java6.seeds":
    source => "puppet:///modules/${module_name}/java6.seeds",
    ensure => present;
  }
}



