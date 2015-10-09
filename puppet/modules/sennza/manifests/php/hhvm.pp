class sennza::php::hhvm (
	$extensions = [],
) {
	apt::source { 'hhvm':
		location    => 'http://dl.hhvm.com/ubuntu',
		release     => 'precise',
		repos       => 'main',
		key_source  => 'http://dl.hhvm.com/conf/hhvm.gpg.key',
		include_src => false
	}
	apt::ppa { 'ppa:mapnik/boost': }

	# Use Ubuntu 12.04's built-in package
	package {'hhvm-fastcgi':
		ensure => latest,
		require => [ Apt::Source['hhvm'], Apt::Ppa['ppa:mapnik/boost'] ]
	}
	package { 'php5-fpm':
		ensure => absent,
	}
	service { 'hhvm':
		ensure => running,
		require => Package[ 'hhvm-fastcgi' ],

		# Ensure it runs at boot
		enable => true,
	}
	service { 'php5-fpm':
		ensure => stopped,
		require => [ Package['php5-fpm'], Service['hhvm'] ],
		hasstatus => false,
	}

	# Ignore extensions
	$prefixed_extensions = prefix($extensions, 'php5-')
	package { $prefixed_extensions:
		# Pretend we're doing something; HHVM has extensions built in instead
		ensure => absent,
		require => Package[ 'php5-fpm' ],
	}

	/*file { '/etc/hhvm.hdf':
		content => template('sennza/hhvm.hdf.erb'),
		owner   => 'root',
		group   => 'root',
		mode    => 0644,
		require => Package['hhvm-fastcgi'],
		ensure  => 'present',
		# notify  => Service['hhvm'],
	}*/
	file { '/etc/hhvm/server.ini':
		content => template('sennza/hhvm-server.ini.erb'),
		owner   => 'root',
		group   => 'root',
		mode    => 0644,
		require => Package['hhvm-fastcgi'],
		ensure  => 'present',
		notify  => Service['hhvm']
	}
}