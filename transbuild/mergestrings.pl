#!/usr/bin/perl
use Encode qw(encode decode);
my ($enca, $encb, $encc) = qw(UTF-16 UTF-16 UTF-16);
my ($filea, $fileb, $filec)=@ARGV;
if($filea=~s/^(.*?)://){
	$enca=$1;
}
if($fileb=~s/^(.*?)://){
	$encb=$1;
}
if($filec=~s/^(.*?)://){
	$encc=$1;
}
warn "output encoding is $encc\n";
my %a;
my %b;
open(A,"<:encoding($enca)",$filea) || die $!;
warn "opened $filea\n";
my $in;
my @order;
while(<A>){
	chomp;
	if(/^"(.*?)" = "(.*?)";$/){
		$a{$1}=$2;
		push @order, $1;
	}
}
close(A) || die $!;

open(B,"<:encoding($encb)",$fileb) || die $!;

my @transorder;
my @unsure;
my @probable;
while(<B>){
	chomp;
	if(/^"(.*?)" = "(.*?)";$/){
		my ($str,$val)=($1,$2);
		$a{$str}=$val if exists $a{$str};
		if(exists $a{$str}){
			if($str eq $val){
				if($str=~/\s/){
					push @probable, $str;
				}else{
					push @unsure, $str;
				}
			}else{
				push @transorder, $str ;
			}
		}
	}
}
close(B) || die $!;
my %trans = map{$_=>1} @transorder;
my %unsure = map{$_=>1} @unsure;
my %probable = map{$_=>1} @probable;
my $out;
$out.=qq{

/* These strings need translation.  Some may not be language strings, and can be ignored. */

};
foreach my $str(@order){
	next if exists $trans{$str} or exists $unsure{$str} or exists $probable{$str};
	my $v = $a{$str};
	$out.=qq{"$str" = "$v";
};
}
if(scalar(@probable) > 0){
$out.=qq{

/* These strings probably need to be translated (contained whitespace) */

};
	
	foreach my $str(@probable){
		my $v = $a{$str};
		$out.=qq{"$str" = "$v";
};
}

}
if(scalar(@unsure) > 0){
$out.=qq{

/* These strings might not be translated, or might be equivalent */

};
	
	foreach my $str(@unsure){
		my $v = $a{$str};
		$out.=qq{"$str" = "$v";
};
}

}
$out.=qq{

/* These strings should be already translated */

};
foreach my $str(@transorder){
	my $v = $a{$str};
	$out.=qq{"$str" = "$v";
};
}
#my $enc = encode($encc,$out);
open(C,">:encoding($encc)",$filec) || die $!;
print C $out;
close(C) || die $!;
print "write ".(length($out))." bytes to $filec\n";

