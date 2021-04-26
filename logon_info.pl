use strict;
use warnings;
use utf8;
use Encode qw( encode decode );

#######################################################
# This tool is run at the Administrator command prompt.
#######################################################

print 'Start (yyyy-mm-dd): ';
chomp( my $start = <STDIN> );

if ( $start !~ /\d\d\d\d\-\d\d\-\d\d/ ){
	print 'The format specified for year, month, and day is invalid.' . "\n";
	exit;
}

print 'End (yyyy-mm-dd): ';
chomp( my $end = <STDIN> );

if ( $end !~ /\d\d\d\d\-\d\d\-\d\d/ ){
	print 'The format specified for year, month, and day is invalid.' . "\n";
	exit;
}

print "\n";

# ID 4624 is a successful logon event that occurred on the local computer.
# ID 4625 is a logon failure event that occurred on the local computer.
# The time is recorded in GMT (Greenwich Mean Time). In the case of Japan Standard Time (JST), 9 hours are subtracted, so 15:00 on the previous day corresponds to 0:00 on that day.
my $cmd = 'wevtutil qe Security /f:Text /q:"*[System[(EventID=4624 or EventID=4625) and TimeCreated[@SystemTime>=\'' . $start . 'T15:00:00.000Z\' and @SystemTime<=\'' . $end . 'T14:59:59.999Z\']]]';

my @results = `$cmd`;

my $date;
foreach my $j ( @results ){
	my $decode_str = decode('cp932', $j);

	if ( $decode_str =~ /Date:/ ){
		$date = encode('cp932', $decode_str);
	}

	# Output if the IP in the logon history matches.
	if ( $decode_str =~ /ソース ネットワーク アドレス.+(192\.(?:[0-9]{1,3})\.(?:[0-9]{1,3})\.(?:[0-9]{1,3}))/ ){
		print $date;
		my $ip = encode('cp932', $decode_str);
		print $ip;
		print "\n";
	}
}

print "Done!\n";
