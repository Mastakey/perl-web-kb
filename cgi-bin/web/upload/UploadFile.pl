#!/usr/bin/perl

use strict;
use warnings;

use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

use File::Basename;

#WEB INIT
print "Content-type: text/html\n\n";

my $upload_filename = param('file_1');
$upload_filename = basename($upload_filename);
$upload_filename =~ s/ /_/g;

my $upload_fh = upload('file_1');

#print $upload_filename;
#print $upload_fh;
if (defined $upload_fh)
{
	my $io_handle = $upload_fh->handle;
	#print $io_handle;
	open my $file_fh, ">uploads/$upload_filename" or die "Can not open file: $!\n"; #UPDATE THIS WITH UPLOAD DIR
	binmode($file_fh); 
	while (my $bytesread = $io_handle->read(my $buffer,1024))
	{
		print $file_fh $buffer;
	}
	close $file_fh;
}    
#my $redir = "http://www.thesite.com/done.htm"; UPDATE THIS
#print $q->redirect("$redir");