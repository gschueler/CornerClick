#!/usr/bin/perl

=head1 WHAT

usage: mergeids.pl a.strings b.strings out.strings
takes the origin strings list of a and creates out by using the OIDs
found in both strings sets, with "out" containing a=b where the OIDS
match.

=cut


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
my %aids;
my $lastoid=undef;
while(<A>){
	chomp;
	if(m{^/\*.*\(oid:(\d+)\) \*/$}){
	   $lastoid=$1;
	}elsif(/^"(.*?)" = "(.*?)";$/){
		$a{$1}=$2;
		push @order, $1;
		$aids{$lastoid}=$1 if defined $lastoid;
		$lastoid=undef;
	}
}
close(A) || die $!;
warn "found oids: ".join(",",keys %aids);

open(B,"<:encoding($encb)",$fileb) || die $!;
warn "opened $fileb\n";

my %bids;
$lastoid=undef;
my @transorder;
my @unsure;
my @probable;
while(<B>){
	chomp;
	if(m{^/\*.*\(oid:(\d+)\) \*/$}){
       $lastoid=$1;
	}elsif(/^"(.*?)" = "(.*?)";$/){
		my ($str,$val)=($1,$2);
		$a{$str}=$val if exists $a{$str};
		if(defined $lastoid){
            $bids{$lastoid}=$val;
            $a{$aids{$lastoid}}=$val if defined $aids{$lastoid} and defined $a{$aids{$lastoid}} ;
            warn "[oid:$lastoid]: present in B, not in A.\n" unless defined  $aids{$lastoid} ;
		}
		$lastoid=undef;
#		if(exists $a{$str}){
#			if($str eq $val){
#				if($str=~/\s/){
#					push @probable, $str;
#				}else{
#					push @unsure, $str;
#				}
#			}else{
#				push @transorder, $str ;
#			}
#		}
	}
}
close(B) || die $!;
my %revids = map{$aids{$_}=>$_}keys %aids;
my $out;
foreach my $str(@order){
	my $v = $a{$str};
	if($revids{$str}){
	$out.=qq{/* (oid:$revids{$str}) */
};
	}
	$out.=qq{"$str" = "$v";

};
}
#my $enc = encode($encc,$out);
open(C,">:encoding($encc)",$filec) || die $!;
print C $out;
close(C) || die $!;
print "write ".(length($out))." bytes to $filec\n";

