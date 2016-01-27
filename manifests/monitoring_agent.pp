# Class: mongodb_ops_manager::monitoring_agent
#
# install mongodb monitoring_agent for mongodb ops manager (mms on premise).
#
#
class mongodb_ops_manager::monitoring_agent(
  $mmsApiKey   = '',
  $mmsGroupId  = '',
  $version     = '2.5.15.1526-1',
  $platform    = '.rhel7',
  $mmsBaseUrl  = 'http://127.0.0.1:8080',
)
{

  exec { 'download-mms-automation-agent':
    command => "curl -OL ${mmsBaseUrl}/download/agent/automation/mongodb-mms-automation-agent-manager-${version}.x86_64${platform}.rpm",
    cwd     => '/tmp',
    creates => "/tmp/mongodb-mms-automation-agent-manager-${version}.x86_64${platform}.rpm",
  }

  exec { 'install-mms-automation-agent':
    cwd     => '/tmp',
    creates => '/run/mongodb-mms-automation',
    command => "rpm -U  \"/tmp/mongodb-mms-automation-agent-manager-${version}.x86_64${platform}.rpm\"",
    require => Exec['download-mms-automation-agent'],
    timeout => 0
  }
  
  file { '/etc/mongodb-mms/automation-agent.config':
    content => template('mongodb_ops_manager/automation-agent.config.erb'),
    owner   => 'mongod',
    group   => 'mongod',
    mode    => '0600',
    require => Exec['install-mms-automation-agent'],
  }
  
  service { 'mongodb-mms-automation-agent':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    restart   => true,
    require   => File['/etc/mongodb-mms/automation-agent.config']
  }  
  
 
}