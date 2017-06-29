#!/usr/bin/perl -w

use KBS2::ImportExport;
use KBS2::Util;
use PerlLib::SwissArmyKnife;

my $importexport = KBS2::ImportExport->new();

my $input = read_file('/home/andrewdo/temp');
foreach my $line (split /\n/, $input) {
  my $res1 = $importexport->Convert
    (
     Input => $line,
     InputType => "KIF String",
     OutputType => "Prolog",
    );
  print $res1->{Output};
}
