class puppet::client {

  file { "/usr/local/bin/puppet-run":

    content => "#! /bin/bash

puppet agent --no-daemonize --onetime --verbose --no-usecacheonfailure",
    mode => "0755"
  }
}
    
