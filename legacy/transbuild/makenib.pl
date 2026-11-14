#!/usr/bin/perl

my $SOURCELANG="English";
my $NIB="ClickBoxPref";
my $BASEDIR=$ENV{BASEDIR} || "$ENV{HOME}/devel/CornerClick";

my $lang=shift @ARGV;

if(!-e "$BASEDIR/$lang.lproj" || !-d "$BASEDIR/$lang.lproj"){
	die "No localization found: $lang\n";
}
my $strings ="$BASEDIR/$lang.lproj/$NIB.strings"; 
if(!-e $strings){

	die "No translated strings file found: $strings\n";
}
my $IN="\"$BASEDIR/$SOURCELANG.lproj/$NIB.nib\"";	

if(system("nibtool -d \"$strings\" -w \"$lang/$NIB.nib\" $IN")){
	die "Failed: $@";
}else{
	warn "created incremental file: $lang/$NIB.nib\n";
}

=head1 WHAT

Converts a Nib from the base language (English) to the translated language,
using the file (NibName).strings inside the lproj of the new language.

E.g.:

perl makenib.pl French

This converts English.lproj/Nib.nib to ./French/Nib.nib using the strings file French.lproj/Nib.strings

=cut
