#!/usr/bin/perl

=head1 WHAT

usage: exportstrings.pl a.strings b.strings out.strings 

takes the origin strings list of a (A:X) and creates out(X:Z) using the any translated versions found in b (A:Z). 

=cut


use Encode qw(encode decode);
my ($enca, $encb, $encc) = qw(UTF-16 UTF-16 UTF-16 UTF-16);
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
my %c;
open(A,"<:encoding($enca)",$filea) || die $!;
warn "opened $filea\n";
my $in;
my @order;
my $ac=0;
my $bc=0;
while(<A>){
	chomp;
	if(/^"(.*?)" = "(.*?)";$/){
		$a{$1}=$2;
		push @order, $1;
        $ac++;
	}else{
        #warn "? $_\n";
    }
}
close(A) || die $!;

#open B
open(B,"<:encoding($encb)",$fileb) || die $!;
warn "opened $fileb\n";

while(<B>){
	chomp;
	if(/^"(.*?)" = "(.*?)";$/){
		$b{$1}=$2;
        $bc++;
        if($a{$1}){
            $c{$a{$1}}=$b{$1};
        }
	}else{
        #    warn "? $_\n";
	}
}
close(B) || die $!;

#iterate A, converting values to the values found in b
my $cc=0;
open(C,">:encoding($encc)",$filec) || die $!;
foreach my $str(keys %c){
    $cc++;
	print C qq{"$str" = "$c{$str}";
};
}
close(C) || die $!;
print "wrote $cc strings to $filec\n";

