use strict;
use warnings;

use FindBin;
use Data::Dumper;
use lib "$FindBin::Bin/../../lib";
use WEBDB;
use CONFIG;
use UTIL;


#CONFIG SUTFF
my $cfg = new CONFIG('../');
my $configDir = $cfg->{CONFIG}->{configDir};

#INPUT
my $parent_id = 0;

#TEMPLATE STUFF
use Template;

my $tmplDir = $cfg->{CONFIG}->{tmplDir};
my $htmlDir = $cfg->{CONFIG}->{htmlDir};
my $htmlcgi = $cfg->{CONFIG}->{htmlcgi};

    my $tmpl_file = 'viewSectionAdd.tmpl';
	my $output_file = 'viewSectionAdd.html';
    my $vars = {
       parent_id => $parent_id,
	   htmlcgi => $htmlcgi,
    };
	
    my $template = Template->new( 
		{
			RELATIVE => 1,
			RECURSION => 1,
			DELIMITER => ';',
			INCLUDE_PATH => $tmplDir.'/web;'.$tmplDir.'/includes',
			OUTPUT_PATH => $htmlDir.'/web',
			PRE_PROCESS => $configDir.'/tmpl.cfg',
		}
	);
    
    $template->process($tmpl_file, $vars, $output_file)
        || die "Template process failed: ", $template->error(), "\n";
