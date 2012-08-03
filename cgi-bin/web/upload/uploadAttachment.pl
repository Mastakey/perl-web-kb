#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use Data::Dumper;
use lib "$FindBin::Bin/../../lib";
use WEBDB;
use CONFIG;
use UTIL;
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use File::Basename;
use Cwd;

$CGI::POST_MAX = 1024 * 5000; #5MB Max

#WEB INIT
print "Content-type: text/html\n\n";

#CONFIG SUTFF

my $cfg = new CONFIG('../');
my $logDir = $cfg->{CONFIG}->{logDir};
my $configDir = $cfg->{CONFIG}->{configDir};
my $db = new WEBDB($cfg->{DBCON}, "", "", $logDir.'/db_uploadAttachment.log');
my $util = new UTIL();
my $uploadDir = $cfg->{CONFIG}->{uploadDir};
my $currentDir = getcwd();

#INPUTS
my $entry_id = param("entry_id");
my $upload_name = param("name");
my $upload_filename = param('file_1');
$upload_filename = basename($upload_filename);
$upload_filename =~ s/ /_/g;

#UNTAINT INPUT
$upload_filename = $util->unTaint($upload_filename);
if ($upload_name eq "")
{
	$upload_name = $upload_filename;
}
else
{
	$upload_name = $util->unTaint($upload_name);
}
#UPLOAD
my $upload_fh = upload('file_1');
if (defined $upload_fh)
{
	my $io_handle = $upload_fh->handle;
	#print $io_handle;
	#CREATE DIR if it does NOT exist
	unless(-e "$uploadDir/$entry_id" or mkdir "$uploadDir/$entry_id") {
		die "Unable to create directory\n";
	}
	open my $file_fh, ">$uploadDir/$entry_id/$upload_filename" or die "Can not open file: $uploadDir/$entry_id/$upload_filename  $!\n Current dir: $currentDir";
	binmode($file_fh); 
	while (my $bytesread = $io_handle->read(my $buffer,1024))
	{
		print $file_fh $buffer;
	}
	close $file_fh;
}  

#VALIDATION
#TODO

#FUNCTIONAL STUFF

#CONNECT TO DB
$db->connect();

#INSERT TO DB
my $attach_id = $util->insertAttachment($db, $upload_name, $upload_filename);
my $entry_attach_id = $util->insertEntryAttachment($db, $entry_id, $attach_id);

#DISCONNECT DB
$db->disconnect();

#TEMPLATE STUFF
use Template;

my $tmplDir = $cfg->{CONFIG}->{tmplDir};
my $htmlDir = $cfg->{CONFIG}->{htmlDir};
my $htmlcgi = $cfg->{CONFIG}->{htmlcgi};
my $cssDir = $cfg->{CONFIG}->{cssDir};

    my $tmpl_file = 'uploadAttachment.tmpl';
	#my $output_file = 'addSection.html';
    my $vars = {
	   entry_id => $entry_id,
	   htmlcgi => $htmlcgi,
	   cssdir => $cssDir, #used by header.tmpl
    };
	
    my $template = Template->new( 
		{
			RELATIVE => 1,
			RECURSION => 1,
			DELIMITER => ';',
			INCLUDE_PATH => $tmplDir.'/web/upload;'.$tmplDir.'/includes',
			OUTPUT_PATH => $htmlDir.'/web/upload',
			PRE_PROCESS => $configDir.'/tmpl.cfg',
		}
	);
    
$template->process($tmpl_file, $vars)
        || die "Template process failed: ", $template->error(), "\n";