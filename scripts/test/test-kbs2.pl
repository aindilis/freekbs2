#!/usr/bin/perl -w

use KBS2::Store::MySQL;

$UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/internal/freekbs2";

my $store = KBS2::Store::MySQL->new
  (
   Database => "freekbs2",
  );
