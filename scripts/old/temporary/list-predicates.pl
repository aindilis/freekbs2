#!/usr/bin/perl -w

use PerlLib::MySQL;

use Data::Dumper;

my $mymysql = PerlLib::MySQL->new
  (DBName => $ARGV[0] || "freekbs2");

my $res = $mymysql->Do
  (Array => 1,
   Statement => "select DISTINCT Value from arguments where KeyID=0;");

print "(setq freekbs2-predicates\n      '(";
foreach my $item (@$res) {
  my $pred = $item->[0];
  if ($pred =~ /^[\w\s-]+$/) {
    print "(\"".$pred."\" . ((\"Arity\" . nil)))\n\t";
  }
}
print "))\n"
