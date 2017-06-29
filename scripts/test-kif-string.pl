#!/usr/bin/perl -w

use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;

my $ie = KBS2::ImportExport->new();

my $res1 = $ie->Convert
  (
   Input => '(p ?X "hi")',
   InputType => "KIF String",
   OutputType => "Interlingua",
  );

print Dumper({Res1 => $res1});

my $res2 = $ie->Convert
  (
   Input => '(p ?X "hi")',
   InputType => "KIF String",
   OutputType => "Emacs String",
  );

print $res2->{Output}."\n";

# is there a namespace collision between a KIF constant which is
# supposed to be written as quoted string, and a KIF string


my $res3 = $ie->Convert
  (
   Input => [
	     [
	      "\"p\"",
	      \*{"::?X"},
	      "\"hi\""
	     ]
	    ],
   InputType => "Interlingua",
   OutputType => "KIF String",
  );

print $res3->{Output}."\n";

my $res4 = $ie->Convert
  (
   Input => [
	     [
	      "国政协提",
	      \*{"::?全"},
	      "\"案聚焦全面\""
	     ]
	    ],
   InputType => "Interlingua",
   OutputType => "KIF String",
  );

print $res4->{Output}."\n";
