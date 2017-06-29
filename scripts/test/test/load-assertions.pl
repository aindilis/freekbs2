#!/usr/bin/perl -w

use Data::Dumper;

# load the network facts temporarily, do not be concerned with how
# they were obtained

use KBS2::Client;

my $assertions =
  [
   '("has-mac-address" "system-1" "<IP>")',
   '("has-hostname" "system-1" "<HOSTNAME>")',
   '("has-type" "system-1" "virtual machine")',
   '("has-mac-address" "system-2" "<IP>")',
   '("has-description" "system-2" "<DESCRIPTION>")',
   '("has-type" "system-2" "WAP")',
   '("has-mac-address" "system-3" "<IP>")',
   '("has-hostname" "system-3" "<HOSTNAME>")',
   '("has-type" "system-3" "desktop")',
   '("has-mac-address" "system-4" "<IP>")',
   '("has-description" "system-4" "<DESCRIPTION>")',
   '("has-type" "system-4" "printer")',
   '("has-mac-address" "system-5" "<IP>")',
   '("has-hostname" "system-5" "<HOSTNAME>")',
   '("has-type" "system-5" "desktop")',
   '("has-mac-address" "system-6" "<IP>")',
   '("has-hostname" "system-6" "<HOSTNAME>")',
   '("has-interface" "system-6" "wlan0")',
   '("has-interface" "system-6" "eth0")',
   '("has-type" "system-6" "laptop")',
   '("has-mac-address" "system-8" "<IP>")',
   '("has-hostname" "system-8" "<HOSTNAME>")',
   '("has-type" "system-8" "desktop")',
   '("has-mac-address" "system-9" "<IP>")',
   '("has-hostname" "system-9" "<HOSTNAME>")',
   '("has-type" "system-9" "desktop")',
   '("has-mac-address" "system-10" "<IP>")',
   '("has-hostname" "system-10" "<HOSTNAME>")',
   '("has-type" "system-10" "desktop")',
  ];

my $client = KBS2::Client->new
  (
   Database => "freekbs2",
   Context => "setanta_agent",
  );
foreach my $assertion (@$assertions) {
  print Dumper($assertion);
  $client->Send
    (
     Assert => $assertion,
     InputType => "Emacs String",
    );
}
