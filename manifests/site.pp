
class build_rpm {

  $packages = [
               "rpmdevtools",
               "gcc",
               "openssl-devel",
               "perl",
               "perl-Moose",
               "perl-MooseX-Getopt",
               "perl-MooseX-Types",
               "perl-MooseX-Types-Path-Class",
               "perl-MooseX-Daemonize",
               "perl-Mouse",
               "perl-Readonly",
               "perl-Exception-Class",
               "perl-Sendmail-PMilter",
               'perl-Authen-SASL',
               'perl-Email-Address',
               'perl-Time-Piece',
               "perltidy",
               'perl-Authen-SASL',
               'perl-Email-Address',
               'perl-Time-Piece',
               "rrdtool-perl",
               "git",
               ]

  yumrepo { "epel":
    descr      => "Extra Packages for Enterprise Linux 6",
    baseurl    => "http://download.fedoraproject.org/pub/epel/6/hardwaremodel",
    mirrorlist => "https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$hardwaremodel",
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => "http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6",
  }

  package { $packages:
    ensure  => latest,
    require => Yumrepo["epel"],
  }

  $build_user  = "devel"
  $build_group = "devel"
  $build_home  = "/home/$build_user"
  $rpmbuild    = "$build_home/rpmbuild"

  group { $build_group:
    ensure => present,
  }
  
  user { $build_user:
    ensure     => present,
    gid        => $build_group,
    home       => $build_home,
    managehome => true,
    require    => Group[$build_group],
  }

  exec { "rpmdev-setuptree":
    command => "/usr/bin/rpmdev-setuptree",
    user    => $build_user,
    cwd     => $build_home,
    creates => $rpmbuild,
    require => [ User[$build_user], Package["rpmdevtools"] ],
  }
  
  file { $rpmbuild:
    ensure => "directory",
    owner  => $build_user,
    group  => "devel",
    require => Exec["rpmdev-setuptree"],
  }

  file { "$build_home/workspace":
    ensure => "directory",
    require => User[$build_user],
  }
}


node "build-rpm" {
  include build_rpm
}  

