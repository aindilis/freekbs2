#!/usr/bin/perl -w

use KBS2::Client;
use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;

my $client = KBS2::Client->new
  (
   Context => "_Contexts",
  );

print Dumper
  ($client->Send
   (
    Command => 'query-cyclike',
    Query => '("generalizes-context" "Org::FRDCSA::Academician" var-X)',
    InputType => 'Emacs String',
   ));
