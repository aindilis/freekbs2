#!/usr/bin/perl -w

use KBS2::ImportExport;

use Data::Dumper;
use File::Slurp;

$UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/internal/freekbs2";

my $ie = KBS2::ImportExport->new;

# load a bunch of CycL (note this is labelled KIF by mistake)

my $extmapping = {
		  "cycl" => "CycL String",
		  "kif" => "KIF String",
		  "pl" => "Perl String",
		  "el" => "Emacs String",
		 };

foreach my $file (split /\n/, `ls data`) {
  if ($file =~ /^.+\.([^\.]+)$/) {
    my $extension = $1;
    if (exists $extmapping->{$extension}) {
      my $inputtype = $extmapping->{$1};
      my $content = read_file("data/$file");

      my $result = $ie->Convert
	(
	 Input => $content,
	 InputType => "CycL String",
	 OutputType => "Interlingua",
	);

      foreach my $type (sort keys %{$ie->Types}) {
	my $result2 = $ie->Convert
	  (
	   InputType => "Interlingua",
	   OutputType => $type,
	   Input => $result->{Output},
	  );
	if ($result2->{Success}) {
	  print "Converting to $type\n";
	  print Dumper({Type => $type});

	  my $output = $result2->{Output};
	  my $type2 = ref $output;
	  if ($type2 eq "") {
	    print "OUTPUT-TO:\n".$output."\n\n";
	  } else {
	    print "OUTPUT-TO:\n".Dumper($output)."\n\n";
	  }

	  print "Converting back from $type to CycL String\n";
	  # now translating back
	  my $result3 = $ie->Convert
	    (
	     Input => $output,
	     InputType => $type,
	     OutputType => "CycL String",
	    );

	  if ($result3->{Success}) {

	    my $output3 = $result3->{Output};
	    my $type3 = ref $output3;
	    if ($type3 eq "") {
	      print "OUTPUT-FROM:\n".$output3."\n\n";
	    } else {
	      print "OUTPUT-FROM:\n".Dumper($output3)."\n\n";
	    }
	    if (Dumper($output3) eq Dumper($result->{Output})) {
	      print "SAME\n";
	    } else {
	      print "WARNING: DIFFERENT!\n";
	    }
	  } else {
	    print Dumper($result3);
	  }
	} else {
	  # print Dumper($result2);
	}
      }
    } else {
      print "No format for extension: <<<$extension>>> for file: <<<$file>>>.\n";
    }
  } else {
    print "No extension found for file: <<<$file>>>.\n";
  }
}
