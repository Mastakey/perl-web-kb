package CONFIG;
use Data::Dumper;

use strict;
use YAML;

#test();

sub new
{
    my $class = shift;
	my $configDir = shift;
	my $configFile = $configDir.'/config.yml';
	open my $file_fh, "<".$configFile or die "Can not open config file\n";

	#convert YAML file to perl hash ref
	my $config = YAML::LoadFile($file_fh);	
	
    my $self = 
    {
		CONFIG => $config,
    };    
    bless $self, $class;
    return $self;
}

sub test
{
	my $cfg = new CONFIG();
	print Dumper($cfg->{CONFIG});
}

1;
