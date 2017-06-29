#!/usr/bin/perl -w

use PerlLib::MySQL;

use Data::Dumper;

sub ListPredicates {
  my $mymysql = PerlLib::MySQL->new
    (DBName => $ARGV[0] || "freekbs2");

  my $context = $ARGV[1] || "default";

  my $res = $mymysql->Do
    (Array => 1,
     Statement => "select DISTINCT a.Value from arguments a,tuples t where a.KeyID=0 and a.TupleID=t.ID and t.Context='$context';");

  print "(setq freekbs2-predicates\n      '(";
  foreach my $item (@$res) {
    my $pred = $item->[0];
    if ($pred =~ /^[\w\s-]+$/) {
      print "(\"".$pred."\" . ((\"Arity\" . nil)))\n\t";
    }
  }
  print "))\n";
}

sub ListContingent {
  
}

ListPredicates(@_);
