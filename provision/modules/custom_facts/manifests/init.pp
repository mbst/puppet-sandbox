class custom_facts {

  file { [ "/etc/facter", "/etc/facter/facts.d" ]:
    ensure => "directory",
    owner => "root",
    group => "root",
    mode => 755
  }

  file { "/etc/facter/facts.d/vagrant.txt":
    content => "vagrant=true",
    require => File["/etc/facter/facts.d"]
  }
}
