#!/usr/bin/perl -w

use KBS2::ImportExport;
use KBS2::Util;
use PerlLib::SwissArmyKnife;

my $importexport = KBS2::ImportExport->new();

my $cycl1 = '(not
              (thereExists ?DESTRUCTION
                (and
                  (isa ?DESTRUCTION DestructionEvent)
                  (inputsDestroyed ?DESTRUCTION TheOneRing))))';

my $res1 = $importexport->Convert
  (
   Input => $cycl1,
   InputType => "CycL String",
   OutputType => "Emacs String",
  );
print "1\n";
print $res1->{Output}."\n";

my $res1a = $importexport->Convert
  (
   Input => $cycl1,
   InputType => "CycL String",
   OutputType => "Prolog",
  );
print "1a\n";
print $res1a->{Output}."\n";


my $res2 = $importexport->Convert
  (
   Input => $res1->{Output},
   InputType => "Emacs String",
   OutputType => "CycL String",
  );
print "2\n";
print $res2->{Output}."\n";

# my $cycl2 = read_file("DesertShieldMt.kif");

# my $res2 = $importexport->Convert
#   (
#    Input => $cycl2,
#    InputType => "CycL String",
#    OutputType => "Interlingua",
#   );
# print DumperQuote2($res2);

my $res10 = $importexport->Convert
  (
   Input => [["#\$isa", \*{"::?Y"}, "#\$Language"]],
   InputType => "Interlingua",
   OutputType => "CycL String",
  );
print "3\n";
print Dumper($res10);
