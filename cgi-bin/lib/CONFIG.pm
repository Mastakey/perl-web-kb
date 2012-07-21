package CONFIG;
use Data::Dumper;

use strict;
use YAML;

#test();

sub new
{
    my $class = shift;
	my $dirOffset = shift;
	my $configFile = $dirOffset.'../config.yml';
	open my $file_fh, "<".$configFile or die "Can not open config file\n";

	#convert YAML file to perl hash ref
	my $config = YAML::LoadFile($file_fh);
	
	my $root = $dirOffset.$config->{root};
	
	#update config hash inplace with ROOT directory
	foreach my $key (keys %$config)
	{
		if ($key =~ m/dir/ig) #Directories only
		{
			$config->{$key} = $root.$config->{$key};
		}
	}
	
    my $self = 
    {
		CONFIG => $config,
		DBCON => $config->{db_odbc_driver}.'dbname='.$config->{dbDir}.'/'.$config->{db_odbc_dbname},
    };    
    bless $self, $class;
    return $self;
}

sub test
{
	my $cfg = new CONFIG();
	print Dumper($cfg->{CONFIG});
	print Dumper($cfg->{DBCON});
}

1;
