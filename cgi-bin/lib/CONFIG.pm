package CONFIG;

use strict;

#test();

#cache this on server if possible
our $cfg_db = "";
our $cfg_rootdir = "";

sub new
{
    my $class = shift;
 	open my $file_fh,  "<".'../config.cfg' or die "Can not open cfg file\n";
	my @lines = <$file_fh>;
	my $root = "";
	foreach my $line (@lines)
	{
		if ($line =~ m/ROOT:(.*)/ig)
		{
			$root = $1;
		}
	}
    my $self = 
    {
    	ROOTDIR => $root
    };    
    bless $self, $class;
    return $self;
}
1;
