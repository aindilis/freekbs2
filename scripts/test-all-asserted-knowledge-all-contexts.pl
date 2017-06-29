#!/usr/bin/perl -w

use KBS2::Client;
use PerlLib::SwissArmyKnife;

my $kbs2 = KBS2::Client->new();

my $res1 = $kbs2->Send
  (
   QueryAgent => 1,
   Command => "all-asserted-knowledge",
   Context => 'all-contexts',
  );

print Dumper($res1);
