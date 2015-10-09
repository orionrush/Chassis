class sennza::php (
	$extensions = [],
	$version = "5.4",
) {
	if $version == "hhvm" {
		class { 'sennza::php::hhvm':
			extensions => $extensions
		}
	}
	else {
		class { 'sennza::php::core':
			extensions => $extensions,
			version    => $version
		}
	}
}