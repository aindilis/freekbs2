#!/usr/bin/perl -w

# lookup in the current context for the entry that matches this

# (has-nl (entry-fn pse number) "")

# use Lingua::EN::Sentence qw(get_sentences);

use BOSS::Config;
use KBS2::Client;
use PerlLib::MySQL;
use PerlLib::SwissArmyKnife;

$specification = q(
	--db <db>		Use this as your database
	--context <context>	Use this as your context
	--has-nl <NL>		Return the entry function for the NL
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $mysql = PerlLib::MySQL->new(DBName => $database);

if (exists $conf->{'--has-nl'}) {
  # do we do it natively, or do we use

  # for speed reasons, look up manually?
  # my $database = $conf->{'--db'} || "freekbs2";
  if (0) {
    my $client = KBS2::Client->new
      (
       Context => $conf->{"--context"} || "default",
      );
  }
}

# my $sentences = get_sentences($search);

$search =~ s/^\W+//;
$search =~ s/\W+$//;

my $quotedsearch = $mysql->Quote($search);
$quotedsearch =~ s/^'//;
$quotedsearch =~ s/'$//;

my $statement = "select * from $table where $field like '%$quotedsearch%'";

if (0) {
  my $OUT;
  open(OUT,">/tmp/statement.txt") or die "ouch!\n";
  print OUT $statement;
  close(OUT);
}

my $res = $mysql->Do
  (Statement => $statement);

if ((scalar keys %$res) >= 1) {
  my @reskeys = keys %$res;
  print Dumper(\@reskeys);
  print $res->{$reskeys[0]}->{$item};
}
