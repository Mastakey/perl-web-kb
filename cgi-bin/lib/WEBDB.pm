package WEBDB;
use DBI;
use Cwd;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use AverSBM ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';  

# Preloaded methods go here.

my $DEBUG = 1;
my $DEBUGFILE = "../../log/webdb.log";
#my $DEBUGFILE = "../../../skeleton/log/webdb.log";

sub new {      
    my $class = shift;
    
    my $self = 
    {
     db => shift,
     user => shift,
     pass => shift,
    };
	$DEBUGFILE = shift;
	my $currentDir = getcwd();
	open(MYFILE, ">>".$DEBUGFILE) or die "Can not open log file $DEBUGFILE: $!\n Current dir: $currentDir";
    bless $self, $class;
    return $self;
}

sub debugLog
{
    my 
    $text = shift;
    if ($DEBUG)
    {
    	open(MYFILE, ">>".$DEBUGFILE);
    	if (defined($text))
    	{
    		print MYFILE $text."\n";
    	}
    	close(MYFILE);
    }
}
    

sub connect 
{
    my $self = shift;
    my $dbh = DBI->connect($self->{db}, $self->{user}, $self->{pass}, {PrintError => 1,RaiseError => 1, LongReadLen => 36000000, }) or die "Couldn't connect to database: " . DBI->errstr;
    $self->{dbh} = $dbh;
    debugLog("Connected to $self->{db}:$self->{user} at ".localtime());
}

sub executeSQL
{
 #RETURNS an ARRAY OF ARRAYREFs
    my $self = shift;
    my $sql = shift;
    my $dbh = $self->{dbh};
    my @returnArray;
    debugLog($sql);
    my $sth = $dbh->prepare($sql) or  die "Couldn't prepare statement: $dbh->errstr" . debugLog($dbh->errstr);
    $sth->execute();
    debugLog($dbh->errstr);
    while (my @data = $sth->fetchrow_array()) 
    {
         push(@returnArray, \@data);
    }
    $sth->finish;
    return \@returnArray;    
}

sub executeSQLHash
{
 #RETURNS an ARRAY OF HASHes
    my $self = shift;
    my $sql = shift;
    my $fields = shift;
    my $dbh = $self->{dbh};
    my @returnArray;
    debugLog($sql);
    my $sth = $dbh->prepare($sql) or die "Couldn't prepare statement: " . $dbh->errstr;

    $sth->execute();
    debugLog($dbh->errstr);
    while (my $data = $sth->fetchrow_hashref()) 
    {
         push(@returnArray, $data);
    }
    $sth->finish;
    return \@returnArray;    
}

sub insertSQL
{
    my $self = shift;
    my $sql = shift;
    my $dbh = $self->{dbh};
    debugLog($sql);
    eval{
        $dbh->do( $sql );    
        1;
    }
    or do
    {
        
        debugLog("Couldn't execute statement: $sql");
        die "Couldn't execute statement: $sql";
    }    #$dbh->commit();
}

sub insertSQLGetLast
{
    my $self = shift;
    my $sql = shift;
	my $table = shift;
	my $idField = shift;
    my $dbh = $self->{dbh};
    debugLog($sql);
    eval{
        $dbh->do( $sql );    
        1;
    }
    or do
    {
        
        debugLog("Couldn't execute statement: $sql");
        die "Couldn't execute statement: $sql";
    };    #$dbh->commit();
	my $id = $dbh->last_insert_id(undef, undef, $table, $idField);
	debugLog("Returned id: $id");
	return $id;
}

sub updateSQL
{
    my $self = shift;
    my $sql = shift;
    my $dbh = $self->{dbh};
    debugLog($sql);
    eval{
        $dbh->do( $sql );    
        1;
    }
    or do
    {
        
        debugLog("Couldn't execute statement: $sql");
        die "Couldn't execute statement: $sql";
    }    #$dbh->commit();
}

sub updateSQLClob
{
    my $self = shift;
    my $sql = shift;
	my $str = shift;
    my $dbh = $self->{dbh};
	my $sth = $dbh->prepare($sql);
	$sth->bind_param(1, $str);
    debugLog($sql);
    eval{
        $sth->execute();    
        1;
    }
    or do
    {
        
        debugLog("Couldn't execute statement: $sql");
        die "Couldn't execute statement: $sql";
    }    #$dbh->commit();
}

sub insertSQLClob
{
    my $self = shift;
    my $sql = shift;
    my $str = shift;
    my $dbh = $self->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->bind_param( 1, $str );
    debugLog($sql);
    eval{
        $sth->execute();    
        1;
    }
    or do
    {
        
        debugLog("Couldn't execute statement: $sql");
        die "Couldn't execute statement: $sql";
    }    #$dbh->commit();
}

sub insertSQLClobGetLast
{
    my $self = shift;
    my $sql = shift;
    my $str = shift;
	my $table = shift;
	my $idField = shift;
    my $dbh = $self->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->bind_param( 1, $str );
    debugLog($sql);
	debugLog("Clob:\n$str");
    eval{
        $sth->execute();    
        1;
    }
    or do
    {
        
        debugLog("Couldn't execute statement: $sql");
        die "Couldn't execute statement: $sql";
    };    #$dbh->commit();
	my $id = $dbh->last_insert_id(undef, undef, $table, $idField);
	debugLog("Returned id: $id");
	return $id;
}

=item
Do not use below! This is for third party SERENA software
sub insertSQLGetLast
{
    my $self = shift;
    my $sql = shift;
    my $dbh = $self->{dbh};
    debugLog($sql);
    my $returnVal = "0";
    eval{
        $dbh->do( $sql );
        my $rs = executeSQL($self, "SELECT TS_LASTID FROM TS_LASTIDS WHERE TS_NAME=\'Scenarios\'"); 
        my $row = $rs->[0];
        $returnVal = $row->[0];
        return $returnVal;
    }
    or do
    {
        
        debugLog("Couldn't execute statement: $sql");
        die "Couldn't execute statement: $sql";
        return "0";
    }    #$dbh->commit();
}
=cut

sub deleteSQL
{
    my $self = shift;
    my $sql = shift;
    my $dbh = $self->{dbh};
    debugLog($sql);
    eval{
        $dbh->do( $sql );    
        1;
    }
    or do
    {
        debugLog("Couldn't execute statement: $sql");
        die "Couldn't execute statement: $sql";
    }
    #$dbh->commit();
}

sub disconnect
{
    my $self = shift;
    my $dbh = $self->{dbh};
    $dbh->disconnect;
    debugLog("Disconnected to $self->{db}:$self->{user} at ".localtime());
}

1;
__END__
