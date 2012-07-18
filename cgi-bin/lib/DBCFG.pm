package DBCFG;

use strict;

#test();

sub new {      
    my $class = shift;
    
    my $self = 
    {
    	FILE => shift,
    	DATABASES => (),
    	#ARRAY OF HASHREF: ({TNS,user,pass})
    };    
    bless $self, $class;
    return $self;
}

sub getConfig
{
    my $self = shift;
    my $file = $self->{FILE};
    my @databases = ();
	open my $fh, "<", $file
	or die "Could not open '$file' - $!";
	my @lines = <$fh>;
	close $fh;
	foreach my $line (@lines)
	{
	    if ($line =~ m/\s*\[/)
	    {
	         #IGNORE All Lines starting with "["
	    }
	    else
	    {
	         my @values = split(",",$line);
	         $values[4] =~ s/\n//;
	         my %hash = (
	         	DRIVER => $values[0],
	         	DBNAME => $values[1],
	         	TNS => $values[2],
	         	USER => $values[3],
	         	PASS => $values[4],
	         );
	         push(@databases, \%hash);
	    }
	}
	$self->{DATABASES} = \@databases;
	return \@databases;
}

sub getConnection
{
    my $self = shift;
    my $dbname = shift;
    my $databases = $self->{DATABASES};
    my %hash = ();
    foreach my $db (@$databases)
    {
        if ($db->{DBNAME} eq $dbname)
        {
            %hash = %$db;
            return \%hash;
        }
    }
}

sub printConfig
{
    my $self = shift;
    my $databases = $self->{DATABASES};
    foreach my $db (@$databases)
    {
    	print $db->{DBNAME}.":".$db->{TNS}.":".$db->{USER}.":".$db->{PASS}."\n";
    }
}

sub test
{
    my $dbcfg = new DBCFG('db.cfg');
    $dbcfg->getConfig();
    $dbcfg->printConfig();
    my $conHash = $dbcfg->getConnection("TES");
    	print $conHash->{DBNAME}.":".$conHash->{TNS}.":".$conHash->{USER}.":".$conHash->{PASS}."\n";

}

1;
