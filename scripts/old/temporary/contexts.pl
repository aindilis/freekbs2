#!/usr/bin/perl -w

use PerlLib::MySQL;

use Data::Dumper;

sub ListContexts {
  my $mymysql = PerlLib::MySQL->new
    (DBName => $ARGV[0] || "freekbs2");

  my $res = $mymysql->Do
    (Array => 1,
     Statement => "select DISTINCT Context from tuples");

  print "(setq freekbs2-contexts\n      '(";
  foreach my $item (@$res) {
    my $context = $item->[0];
    if ($context =~ /^[\w\s-]+$/) {
      print "(\"".$context."\" . t)\n\t";
    }
  }
  print "))\n";
}

ListContexts(@_);
