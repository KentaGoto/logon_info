use strict;
use warnings;
use utf8;
use Encode qw( encode decode );

###################################################
# このツールは、管理者コマンドプロンプトで実行する
###################################################

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

# ID 4624 は、ローカルコンピューター上で発生したログオン成功イベント。
# ID 4625 は、ローカルコンピューター上で発生したログオン失敗イベント。
# 時間は GMT (グリニッジ標準時) で記録されている。日本標準時 (JST) の場合 9 時間を差し引くため、前日の 15 時がその日の 0 時に相当する。
my $cmd = 'wevtutil qe Security /f:Text /q:"*[System[(EventID=4624 or EventID=4625) and TimeCreated[@SystemTime>=\'' . $start . 'T15:00:00.000Z\' and @SystemTime<=\'' . $end . 'T14:59:59.999Z\']]]';

my @results = `$cmd`;

my $date;
foreach my $j ( @results ){
	my $decode_str = decode('cp932', $j);

	if ( $decode_str =~ /Date:/ ){
		$date = encode('cp932', $decode_str);
	}

	# ログオン履歴のIPにマッチしたら出力
	if ( $decode_str =~ /ソース ネットワーク アドレス.+(192\.(?:[0-9]{1,3})\.(?:[0-9]{1,3})\.(?:[0-9]{1,3}))/ ){
		print $date;
		my $ip = encode('cp932', $decode_str);
		print $ip;
		print "\n";
	}
}

print "Done!\n";
