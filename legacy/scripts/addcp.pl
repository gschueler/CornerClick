#!/usr/bin/perl

=head1 ABOUT

Prepends a copyright file to all files matching a filepattern within a directory.

It finds all files matching the pattern in the dir, and opens a temp file to write to
it then writes the contents of the cp.txt file and then writes the contents of the
matched file.  It then renames the temp file to the matched file name to replace
it.

=cut


=head1 USAGE

  addcp.pl <cp.txt> <pattern> <dir>

=cut

use strict;

print "args ".scalar(@ARGV)."\n";
print "args @ARGV\n";
unless(scalar(@ARGV)==3){
	die "usage: <cp.txt> <pattern> <dir>\n"
}

my $CPF=shift @ARGV;
my $pat=shift @ARGV;
my $dir=shift @ARGV;
unless($CPF and $pat and $dir){
	die "usage: <cp.txt> <pattern> <dir>\n"
}
my $cpt;
{
	local $/;
	open(CPF,$CPF) || die "couldn't open file $CPF: $!";
	$cpt=<CPF>;
	close(CPF) || die "couldn't close file: $!";
}
print $cpt;
my @dirs;
push @dirs,$dir;

foreach my $dd(@dirs){
	#print "readdir: $dd\n";
	opendir(DIR,$dd) || die "couldn't open dir $dir: $!\n";
	my @readdir=readdir(DIR);
	closedir DIR;
	my @files = grep { /$pat/ && -f "$dd/$_" } @readdir;

	for(@files){
		print "file: $dd/$_\n";
		# open temp file and print copyright, then file contents
		my $oldname="$dd/$_";
		my $tmpname=$oldname.".tmpz";
		open (FW,">$tmpname") || die "unable to write temp file for $dd/$_: $!";
		open (FR,"<$oldname") || die "unable to read file for $dd/$_: $!";
		print FW $cpt;
		
		foreach my $line(<FR>){
			print FW $line;
		}
		close(FR) || die "couldn't close file: $!";
		close(FW) || die "couldn't close temp file: $!";
		
		#move temp file to file
		rename $tmpname,$oldname || die "Unable to rename temp file: $!";
	}
	my @ddirs = grep { /^[^.]/ && -d "$dd/$_" } @readdir;
	
	if(scalar(@ddirs)>0){
		#print "dirs: @ddirs\n";
		map{push @dirs,"$dd/$_"} @ddirs;
	}
	
}
