name 'development'
description 'The development environment'
zookeeper_hosts = %w[10.1.1.2]
override_attributes( 
	'zookeeper-platform': {
		'hosts': zookeeper_hosts
	},
	'confluent-platform': {
	 	'kafka': {
	 		'hosts': %w[10.1.1.3],
	 		'cli_opts': {
	 			'-Xms4g': 'nil',
  				'-Xmx4g': 'nil',
	 			'-Xms1g': '',
				'-Xmx2g': '',
	 		},
	 		'config': {
	 			'advertised.listeners': 'PLAINTEXT://10.1.1.3:9092',
	 		}
	 	},
	 	'zookeeper': {
	 		'hosts': zookeeper_hosts
 		}
 	}
 )