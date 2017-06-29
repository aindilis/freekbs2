#!/usr/bin/perl -w

use KBS2::ImportExport;

use Data::Dumper;

my $ie = KBS2::ImportExport->new;

foreach my $query (
		   '("has-NL" ("entry-fn" "pse" "10") "fix the extract-movie-clip system, it wasn\'t working quite right. add ability to extract from all scripts simultaenously and compare results.")',
		   '("costs" "item" "$400")',
		   '("costs" "item" "-40+\$0")',
		   '("costs" "item" "\400")',
		   '("costs" "item" "+400")',
		   '("has-postal-address" ("contact-fn" 1135) ("address-fn" "200 South Wacker Dr, Chicago, IL 60606"))',
		   '("has-location"
 ("address-fn" "200 South Wacker Dr, Chicago, IL 60606")
 ("lat-long-fn" ("latitude-fn" "41.880537") ("longitude-fn" "-87.637038")))',
		   '("diagonal" "positive" "0")',
		   '("plus" "5" "-10")',
		   '("temp" "a" "b" "c")',
		   '("temp" "d" "e" "f")',
		   '("temp" "g" "h" "i")',
		   '("temp" var-X var-Y var-Z)',
		  ) {
  print Dumper($ie->Convert
	       (
		Input => $query,
		InputType => "Emacs String",
		# OutputType => "Interlingua",
		OutputType => "KIF String",
	       )->{Output});
}

foreach my $query (
		   '(=> (and (genls ?A ?B) (genls ?B ?C)) (genls ?A ?C))',
		   '(- 5 10)',
		   '(- 5 (- 10))',
		   '(temp a b c)',
		   '(temp d e f)',
		   '(temp g h i)',
		   '(temp ?X ?Y ?Z)',
		  ) {
  print Dumper($ie->Convert
	       (
		Input => $query,
		InputType => "KIF String",
		OutputType => "Emacs String",
	       )->{Output});
}
