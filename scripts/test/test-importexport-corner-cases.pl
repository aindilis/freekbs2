#!/usr/bin/perl -w

use KBS2::ImportExport;

use Data::Dumper;

my $ie = KBS2::ImportExport->new;
my $res = $ie->Convert
  (
   Input => "(kbs2_kif_quote_321)",
   InputType => "KIF String",
   OutputType => "Interlingua",
  );
print Dumper($res->{Output}->[0]->[0]);
