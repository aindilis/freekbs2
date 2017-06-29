#!/usr/bin/perl -w

use PerlLib::MySQL;

use Data::Dumper;

sub ListPredicates {
  my $mysql = PerlLib::MySQL->new
    (DBName => $ARGV[0] || "freekbs2");

  my $context = $ARGV[1] || "default";

  my $res = $mysql->Do
    (Array => 1,
     Statement => "select distinct(a.value) from formulae f, arguments a, metadata m, contexts c where f.ParentFormulaID = -1 and a.ParentFormulaID = f.ID and a.KeyID = 0 and m.FormulaID = f.ID and m.ContextID = c.ID and c.Context = '$context';");

  print "(setq freekbs2-predicates\n      '(";
  foreach my $item (@$res) {
    my $pred = $item->[0];
    if ($pred =~ /^[\w\s-]+$/) {
      print "(\"".$pred."\" . ((\"Arity\" . nil)))\n\t";
    }
  }
  print "))\n";
}

ListPredicates(@_);
