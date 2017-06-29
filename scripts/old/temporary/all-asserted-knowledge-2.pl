#!/usr/bin/perl -w

use KBS2::Store::MySQL;
use KBS2::Util;
use PerlLib::MySQL;

use Data::Dumper;

my $mysql = PerlLib::MySQL->new
  (DBName => "freekbs2");

my $quoted = $mysql->DBH->quote($ARGV[0]);
foreach my $entry
  (@{$mysql->Do
   (
    Statement => "select distinct TupleID from arguments where Value=$quoted;",
    Array => 1,
   )}) {
  print RelationToString
    (Type => "Emacs",
     Relation => Retrieve(ID => $entry->[0]))."\n";
}

sub Retrieve {
  my (%args) = @_;
  my $r2 = $mysql->Do(Statement => "select * from arguments where TupleID=$args{ID}");
  my @rec;
  foreach my $aid (keys %$r2) {
    $rec[$r2->{$aid}->{KeyID}] = $r2->{$aid}->{Value};
  }
  return \@rec;
}
