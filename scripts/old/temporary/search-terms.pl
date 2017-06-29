#!/usr/bin/perl -w

# lookup in the database for the goal that matches this

# use Lingua::EN::Sentence qw(get_sentences);
use Data::Dumper;
use PerlLib::MySQL;

my $database = "freekbs2";
my $table = "arguments";
my $field = "Value";
my $item = "Value";
my $search = shift;

# my $sentences = get_sentences($search);
my $mysql = PerlLib::MySQL->new(DBName => "$database");

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
  my $keys = {};
  foreach my $key (map {$res->{$_}->{$item}} @reskeys) {
    $keys->{$key} = 1;
  }
  print Dumper([sort keys %$keys]);
}

