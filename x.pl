#!/usr/bin/perl

use strict;
use warnings;
use Time::Local;

my $mailxcmd = "mailx -N -A csiro -f \"+eIridium SBD\"";
my $msglist = ":u (subject \"sbd msg\")";

my $solo2dir = "/home/argo/ArgoRT/solo2_data/mail";
die "$solo2dir does not exist.\n" unless -d $solo2dir;

my $otherdir = "/home/UOT/programs/Mquest/SBDmessages";
die "$otherdir does not exist.\n" unless -d $otherdir;

my $iridiumids = "/home/argo/ArgoRT/spreadsheet/IridiumCommsIDs.csv";
die "$iridiumids does not exist.\n" unless -f $iridiumids;

my %solo2;

# Get the ids of the SOLO II floats.

open(ID, "<", $iridiumids) || die "$iridiumids: $!\n";
undef $/;
my $id = <ID>;
$/ = "\n";
close(ID);

for (split(/[\r\n]+/, $id)) {
	my @col = split(/,/);
	if (defined($col[8]) && $col[8] =~ /SOLO II/) {
		$solo2{$col[5]}++;
	}
}

my $tmpdir = "/tmp/sbd$$";
mkdir($tmpdir);
chdir($tmpdir);

open(NAIL, "-|", "echo -e 'set headline=\"%m %s\"\\nfrom $msglist' | $mailxcmd");
while (<NAIL>) {
	chomp;
	if (my ($msgnum, $unit) = (/^ *(\d+).*SBD Msg From Unit: (\d+)/)) {
		if ($solo2{$unit}) {
			&do_solo2($msgnum);
		} else {
			&do_other($msgnum);
		}
	}
}
close(NAIL);

chdir("/tmp");
rmdir($tmpdir);

sub do_solo2 {
	my ($msgnum) = @_;

	system("echo 'save $msgnum sbdmsg' | $mailxcmd > /dev/null");
	open(MSG, "<", "sbdmsg");
	undef $/;
	my $msg = <MSG>;
	$/ = "\n";
	close(MSG);

	if (my ($attname) = ($msg =~ /Content-Disposition: attachment; filename="([^"]*)/)) {
		$attname =~ s/\.sbd//;
		system("mv sbdmsg $solo2dir/$attname.eml");
	} else {
		unlink("sbdmsg");
	}
}

sub do_other {
	my ($msgnum) = @_;

	system("echo 'write $msgnum /dev/null' | $mailxcmd > /dev/null");

	my @att = <*>;

	system("mv $att[0] $otherdir") if @att;
}
