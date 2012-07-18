use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Template;

    my $tmpl_file = 'index.tmpl';
	my $output_file = 'index.html';
    my $vars = {
       perlmessage  => "This is a perl variable"
    };
	
    my $template = Template->new( 
		{
			RELATIVE => 1,
			INCLUDE_PATH => '../../tmpl:../../tmpl/includes',
			OUTPUT_PATH => '../../html',
			PRE_PROCESS => '../../config/tmpl.cfg',
			#IF cgi-bin is shared:
			#INCLUDE_PATH => '../../../skeleton/tmpl:../../../skeleton/tmpl/includes',
			#OUTPUT_PATH => '../../../skeleton/html',
			#PRE_PROCESS => '../../../skeleton/config/tmpl.cfg',
		}
	);
    
    $template->process($tmpl_file, $vars, $output_file)
        || die "Template process failed: ", $template->error(), "\n";