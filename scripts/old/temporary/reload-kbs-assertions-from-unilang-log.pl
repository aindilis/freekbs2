#!/usr/bin/perl -w

use PerlLib::MySQL;

use Data::Dumper;

my $mysql = PerlLib::MySQL->new
  (DBName => "unilang");

my $res = $mysql->Do
  (Statement => "select * from messages where Contents like 'KBS2, MySQL:freekbs2:default%'");

foreach my $key (sort {$a <=> $b} keys %$res) {
  # print "$key\n";
  if ($res->{$key}->{Contents} =~ /KBS2, MySQL:freekbs2:default (un)?assert/) {
    print $res->{$key}->{Contents}."\n";
  }
}
