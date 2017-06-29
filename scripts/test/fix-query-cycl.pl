#!/usr/bin/perl -w

use KBS2::Client;

use Data::Dumper;

my $client = KBS2::Client->new;

my $res1 = $client->Send
  (
   Command => "clear-context",
   Context => "Org::FRDCSA::Audience::MPS",
  );
print Dumper($res1);

foreach my $item ("Meaningful Objectives: Business", "Meaningful Objectives: Personal", "Supporting Projects: Business", "Supporting Projects: Personal", "The 1:1 Meetings") {
  my $res = $client->Send
    (
     Assert => [["audience-message-class", $item]],
     InputType => "Interlingua",
     Context => "Org::FRDCSA::Audience::MPS",
     QueryAgent => 1,
    );
  print Dumper($res);
}

my $res2 = $client->Send
  (
   Query => "(audience-message-class ?X)",
   InputType => "KIF String",
   Context => "Org::FRDCSA::Audience::MPS",
   QueryAgent => 1,
  );

print Dumper($res2);
