#!/usr/bin/perl -w

use KBS2::ImportExport;
use KBS2::Util;
use PerlLib::SwissArmyKnife;

my $importexport = KBS2::ImportExport->new();

my $cycl1 = '(#$holdsIn
  (#$TimeIntervalInclusiveFn
   (#$DayFn 2
    (#$MonthFn #$August
     (#$YearFn 1990)))
   (#$DayFn 27
    (#$MonthFn #$February
     (#$YearFn 1991))))
  (#$beliefs #$UnitedStatesOfAmerica
   (#$goals #$Iraq
    (#$thereExists
     ?ATTACK
     (#$thereExists
      ?WEAPON
      (#$and
       (#$isa ?ATTACK #$MilitaryAttack)
       (#$isa ?WEAPON #$WeaponOfMassDestruction)
       (#$performedBy ?ATTACK #$Iraq)
       (#$intendedMaleficiary ?ATTACK
        (#$ArmyFn #$UnitedStatesOfAmerica))
       (#$deviceUsed ?ATTACK ?WEAPON)))))))
(#$holdsIn
  (#$TimeIntervalInclusiveFn
   (#$DayFn 2
    (#$MonthFn #$August
     (#$YearFn 1990)))
   (#$DayFn 27
    (#$MonthFn #$February
     (#$YearFn 1991))))
  (#$beliefs #$UnitedStatesOfAmerica
   (#$goals #$Iraq
    (#$thereExists
     ?ATTACK
     (#$thereExists
      ?WEAPON
      (#$and
       (#$isa ?ATTACK #$MilitaryAttack)
       (#$isa ?WEAPON #$WeaponOfMassDestruction)
       (#$performedBy ?ATTACK #$Iraq)
       (#$intendedMaleficiary ?ATTACK
        (#$ArmyFn #$UnitedStatesOfAmerica))
       (#$deviceUsed ?ATTACK ?WEAPON)))))))';

my $res1 = $importexport->Convert
  (
   Input => $cycl1,
   InputType => "ResearchCyc1_0API",
   OutputType => "Emacs String",
  );
print "Res1\n".$res1->{Output}."\n";

# my $res2 = $importexport->Convert
#   (
#    Input => $res1->{Output},
#    InputType => "Emacs String",
#    OutputType => "ResearchCyc1_0API",
#   );
# print "Res2\n".$res2->{Output}."\n";

my $res2 = $importexport->Convert
  (
   Input => $cycl1,
   InputType => "ResearchCyc1_0API",
   OutputType => "Interlingua",
  );
print Dumper({Res2 => $res2->{Output}});

# my $res3 = $importexport->Convert
#   (
#    Input => $cycl1,
#    InputType => "ResearchCyc1_0API",
#    OutputType => "Interlingua",
#   );
# print DumperQuote2($res2);

# my $res10 = $importexport->Convert
#   (
#    Input => [["#\$isa", \*{"::?Y"}, "#\$Language"]],
#    InputType => "Interlingua",
#    OutputType => "ResearchCyc1_0API",
#   );
# print Dumper($res10);
