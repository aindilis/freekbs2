#!/usr/bin/perl -w

use KBS2::ImportExport;
use KBS2::Util;
use PerlLib::SwissArmyKnife;

my $importexport = KBS2::ImportExport->new();

my $prolog = read_file('/var/lib/myfrdcsa/codebases/minor/suppositional-reasoner/Suppose/Resources/chess/chesskb/board-standard.pro');

my $res1 = $importexport->Convert
  (
   Input => $prolog,
   InputType => "Prolog",
   OutputType => "Emacs String",
  );
print $res1->{Output}."\n";

my $res2 = $importexport->Convert
  (
   Input => $res1->{Output},
   InputType => "Emacs String",
   OutputType => "Prolog",
  );
print $res2->{Output}."\n";


# my $cycl2 = read_file("DesertShieldMt.kif");

# my $res2 = $importexport->Convert
#   (
#    Input => $cycl2,
#    InputType => "CycL String",
#    OutputType => "Interlingua",
#   );
# print DumperQuote2($res2);

# my $res10 = $importexport->Convert
#   (
#    Input => [["#\$isa", \*{"::?Y"}, "#\$Language"]],
#    InputType => "Interlingua",
#    OutputType => "Prolog",
#   );
# print Dumper($res10);
