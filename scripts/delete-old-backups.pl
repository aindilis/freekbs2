#!/usr/bin/perl -w

use Data::Dumper;
use File::Stat;
use DateTime;

my $backupdir = "/var/lib/myfrdcsa/codebases/data/freekbs2/kbs2-backups";

my @dirs = split /\n/, `ls -1 $backupdir`;
foreach my $dir (@dirs) {
  my $stat = File::Stat->new("$backupdir/$dir");
  $dt = DateTime->from_epoch( epoch => $stat->ctime );
  $ndt = DateTime->now;
  my $dtd = $ndt->subtract_datetime( $dt );
  if ($dtd->weeks >= 2) {
    # delete this dir
    print "Moving $dir to temp for deletion\n";
    system "mv \"$backupdir/$dir\" /tmp";
  }
}
