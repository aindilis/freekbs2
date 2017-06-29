#!/usr/bin/perl -w

use KBS2::Util;
use PerlLib::MySQL;

use Data::Dumper;

my $mysql = PerlLib::MySQL->new
  (DBName => "unilang");

my @senders = qw(UniLang-Client Manager Recovery-FRDCSA UniLang-IRC-Bot Emacs-Client PSE-X);
my $approvedsenders = "(".join(" or ",map {"Sender='$_'"} @senders).")";

my $res = $mysql->Do
  (
   Statement => "select * from messages where $approvedsenders and Contents != 'Register'",
  );

my @list;
foreach my $key (sort {$b <=> $a} keys %$res) {
  my $item = "(".EmacsQuote(Arg => $res->{$key}->{Contents})." . $key)";;
  # print $item."\n";
  push @list, $item;
}

print "(\n".join("\n",@list)."\n)";
