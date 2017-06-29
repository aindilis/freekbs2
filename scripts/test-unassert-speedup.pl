#!/usr/bin/perl -w

use KBS2::Client;

# use PerlLib::MySQL;


my $client = KBS2::Client->new
  (
   Context => "test",
  );

my $formula = ["isa","x","y"];
$client->Send
  (
   QueryAgent => 1,
   Assert => [$formula],
   InputType => "Interlingua",
   Context => "test",
  );

system "kbs2 -c test show";

$client->Send
  (
   QueryAgent => 1,
   Unassert => [$formula],
   InputType => "Interlingua",
   Context => "test",
  );

system "kbs2 -c test show";
