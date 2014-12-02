# == Class: puppet::server
#
# This class installs and manages the Puppet server daemon.
#
# === Parameters
#
# [*ensure*]
#   What state the package should be in. Defaults to +latest+. Valid values are
#   +present+ (also called +installed+), +absent+, +purged+, +held+, +latest+,
#   or a specific version number.
#
# [*package_name*]
#   The name of the package on the relevant distribution. Default is set by
#   Class['puppet::params'].
#
# === Actions
#
# - Install Puppet server package
# - Install puppet-lint gem
# - Configure Puppet to autosign puppet client certificate requests
# - Configure Puppet to use nodes.pp and modules from /vagrant directory
# - Ensure puppet-master daemon is running
#
# === Requires
#
# === Sample Usage
#
#   class { 'puppet::server': }
#
#   class { 'puppet::server':
#     ensure => 'puppet-2.7.17-1.el6',
#   }
#
class puppet::server(
  $ensure       = $puppet::params::server_ensure,
  $package_name = $puppet::params::server_package_name
) inherits puppet::params {

  # required to prevent syslog error on ubuntu
  # https://bugs.launchpad.net/ubuntu/+source/puppet/+bug/564861
  file { [ '/etc/puppet' ]:
    ensure => directory,
    before => Package[ 'puppetmaster' ],
  }

  file { '/etc/puppet/manifests': 
    ensure => 'link',
    target => '/puppet/manifests/',
    require => File['/etc/puppet'],
    before => Package [ 'puppetmaster' ]
  }

  file { '/etc/puppet/modules': 
    ensure => 'link',
    target => '/puppet/modules/',
    require => File['/etc/puppet'],
    before => Package [ 'puppetmaster' ]
  }

  file { '/etc/puppet/puppet.conf': 
    ensure => 'link',
    target => '/puppet/modules/puppet/files/puppet.conf',
    require => File['/etc/puppet'],
    before => Package [ 'puppetmaster' ]
  }

  file { '/etc/puppet/hiera.yaml': 
    ensure => 'link',
    target => '/puppet/modules/puppet/files/hiera.yaml',
    require => File['/etc/puppet'],
    before => Package [ 'puppetmaster' ]
  }

  file { '/etc/puppet/hieradata': 
    ensure => 'link',
    target => '/puppet/hieradata',
    require => File['/etc/puppet'],
    before => Package [ 'puppetmaster' ]
  }

  package { 'puppetmaster':
    ensure => $ensure,
    name   => $package_name,
  }

  package { 'puppet-lint':
    ensure   => latest,
    provider => gem,
  }

  file { 'autosign.conf':
    path    => '/etc/puppet/autosign.conf',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    content => '*',
    require => Package[ 'puppetmaster' ],
  }

  # initialize a template file then ignore
  file { '/vagrant/nodes.pp':
    ensure  => present,
    replace => false,
    source  => 'puppet:///modules/puppet/nodes.pp',
  }

  service { 'puppetmaster':
    enable => true,
    ensure => running,
    require => File [ 'autosign.conf' ]
  }

}
