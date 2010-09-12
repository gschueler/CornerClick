#!/usr/bin/perl

=head1 WHAT

usage: transstrings.pl a.strings b.strings out.strings [missing.strings]
takes the origin strings list of a (A:X) and creates out(A:Z) using the any translated versions found in b (X:Z), and  including any untranslated strings from a. Optionally writes the missing translations into missing.strings

used in ../Makefile to generated translation strings files to apply to English.xib into localized xibs.
=cut


use Encode qw(encode decode);
my ($enca, $encb, $encc, $encd) = qw(UTF-16 UTF-16 UTF-16 UTF-16);
my ($filea, $fileb, $filec, $filed)=@ARGV;
if($filea=~s/^(.*?)://){
	$enca=$1;
}
if($fileb=~s/^(.*?)://){
	$encb=$1;
}
if($filec=~s/^(.*?)://){
	$encc=$1;
}
if($filed=~s/^(.*?)://){
	$encd=$1;
}
warn "output encoding is $encc\n";
my %a;
my %b;
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
	}else{
        #    warn "? $_\n";
	}
}
close(B) || die $!;

#iterate A, converting values to the values found in b

open(C,">:encoding($encc)",$filec) || die $!;
my $missingc=0;
if($filed){
    open(D,">:encoding($encd)",$filed) || die $!;
    print D qq{
    /* Strings in $filea without matches in $fileb follow */
};
}
foreach my $str(@order){
	my $v = $a{$str};
    if($b{$v}){
        $a{$str}=$b{$v};
    }elsif($filed){
        $missingc++;
	    print D qq{"$str" = "$a{$str}";
};
    }
	print C qq{"$str" = "$a{$str}";
};
}
close(C) || die $!;
print "wrote $ac strings to $filec ($bc translations, $missingc missing)\n";
if($filed){
    close(D) || die $!;
    print "wrote $missingc strings to $filed\n";
}

