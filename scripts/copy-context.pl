#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::MySQL;
use PerlLib::SwissArmyKnife;

$specification = q(
	-d <dbname>		DBName to work with
	-c <context>		List existing searches
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $mysql = PerlLib::MySQL->new
  (DBName => $conf->{'-d'} || "freekbs2");

sub ListPredicates {
  my (%args) = @_;
  my $context = $conf->{'-c'};
  die "No context\n" unless $context;

  my $res = $mysql->Do
    (Array => 1,
     Statement => "select distinct(a.value) from formulae f, arguments a, metadata m, contexts c where f.ParentFormulaID = -1 and a.ParentFormulaID = f.ID and a.KeyID = 0 and m.FormulaID = f.ID and m.ContextID = c.ID and c.Context = '$context';");

  print "(setq freekbs2-predicates\n      '(";
  foreach my $item (@$res) {
    my $pred = $item->[0];
    if ($pred =~ /^[\w\s-]+$/) {
      print "(\"".$pred."\" . ((\"Arity\" . nil)))\n\t";
    }
  }
  print "))\n";
}

ListPredicates();
