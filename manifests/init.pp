# Class: java
#
# Parameters:
#   The parameters listed here are not required in general and were
#     added for use cases related to development environments.
#   versions      - JDKs to be installed
#   java_home_for - Name of the JDK to be set as $JAVA_HOME
# Actions:
#
# Requires:
#   puppetlabs/apt
#
# Sample Usage:
#  class { 'java': }

class java(
  $versions      = [ 'Oracle 1.6' ],
  $java_home_for = 'Oracle 1.6'
) {
  include apt

  jdk { $versions: java_home_for => $java_home_for }

  define jdk($java_home_for) {
    $jdk = split($name, ' ')

    $jdk_name    = $jdk[0]
    $jdk_version = $jdk[1]

    case $jdk_name {
      oracle: {
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

        $java_home = '/usr/lib/jvm/java-6-oracle'
      }
      ibm:  {
        package { 'ibm-6-jdk':
          require      => Apt::Ppa['ppa:vermeulen-mp/ibm-jdk'],
          ensure       => latest;
        }

        apt::ppa { 'ppa:vermeulen-mp/ibm-jdk': }

        $java_home = '/usr/lib/jvm/java-6-ibm'
      }
      default: { fail("Unrecognized ") }
    }

    if $java_home_for == $name {
        file { "/etc/profile.d/set_java_home.sh":
            ensure => present,
            content => "export JAVA_HOME='${java_home}'";
        }
    }
  }
}