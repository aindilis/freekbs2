#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;

$specification = q(
        --sim           Simulate, but don't actually create a backup

        --public        Only include data for items that should be public, i.e. CSO / Datamart versus UniLang
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;

my $tableinfo =
  {
   "extended-wordnet" => {
			  "P-N" => 1,
			 },
  };

my $backupdir = "/var/lib/myfrdcsa/codebases/data/freekbs2/kbs2-backups";

my $date = `date '+%G%m%d%H%M%S'`;
chomp $date;
my $dir = "$backupdir/$date";
system "mkdir -p ".shell_quote($dir);

foreach my $context (split /\n/, `kbs2 -l`) {
  # print "<$context>";
  my $command = "kbs2 -c ".shell_quote($context)." show > ".shell_quote("$dir/$context.kbs");
  print $command."\n";
  system $command;
}

if (! $conf->{'--sim'}) {
  system "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/delete-old-backups.pl";
}
