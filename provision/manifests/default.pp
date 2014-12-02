#
# site.pp - defines defaults for vagrant provisioning
#

# use run stages for minor vagrant environment fixes
stage { 'pre': before => Stage['main'] }

class { 'repos':   stage => 'pre' }
class { 'vagrant': stage => 'pre' }

class { 'puppet': }
class { 'networking': }
class { 'custom_facts': }

if $hostname == 'puppet' {
  class { 'puppet::server': }
} else {
  class { 'puppet::client': }
}

