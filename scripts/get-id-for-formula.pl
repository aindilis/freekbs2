#!/usr/bin/perl -w

use PerlLib::MySQL;
use PerlLib::SwissArmyKnife;

my $formula;
my $context;
my $database;
if (0) {
  $formula = ["has-NL", ["entry-fn", "pse", "82"], "Get off my pop addiction."];
  $context = "Org::FRDCSA::Verber::PSEx2::Do";
  $database = "freekbs2";
} elsif (0) {
  $formula = ["p","a"];
  $context = "test-kbs2-vampire";
  $database = "freekbs2";
} else {
  $formula = [
                            'depends',
                            [
                              'entry-fn',
                              'pse',
                              '128'
                            ],
                            [
                              'entry-fn',
                              'pse',
                              '52'
                            ]
                          ];
  $context = "Org::FRDCSA::Verber::PSEx2::Do";
  $database = "freekbs2-test";
}
my $mysql = PerlLib::MySQL->new
  (
   DBName => $database,
  );
print Dumper
  (GetIDForFormula
   (
    Formula => $formula,
    Context => $context,
   ));

sub GetIDForFormula {
  my %args = @_;
  # select m.ID from metadata m, formulae f1, arguments a1, arguments a2 where f1.ID=m.FormulaID and a1.ParentFormulaID=f1.ID and a1.Value='p' and a2.ParentFormulaID=f1.ID and a2.Value='b';
  my $wheres = $args{Wheres} || {};
  my $contextid;
  if (! $args{Subroutine}) {
    if (exists $args{Context}) {
      # obtain the id for this context
      my $res = $mysql->Do
	(
	 Statement => "select ID from contexts where Context=".$mysql->Quote($args{Context}),
	);
      my @keys = keys %$res;
      if (scalar @keys) {
	$contextid = shift @keys;
      } else {
	return {
		Success => 0,
		Reason => "context <".$args{Context}."> not found\n",
	       };
      }
    }
    $wheres->{"f1.ID=m.FormulaID"} = 1;
  }
  my $parentformulavar = $args{ParentFormulaVar} || "f1";
  my $formulavars = $args{FormulaVars} || {
					   "f1" => 1,
					  };
  my $formulavarsindex = $args{FormulaVarsIndex} || 2;
  my $argumentvars = $args{ArgumentVars} || {};
  my $argumentvarsindex = $args{ArgumentVarsIndex} || 1;

  foreach my $item (@{$args{Formula}}) {
    my $itemtype = ref $item;
    if ($itemtype eq "ARRAY") {
      # this would be a subformula, create a new variable for it

      my $formulavar = "f$formulavarsindex";
      $formulavars->{$formulavar} = 1;
      ++$formulavarsindex;
      $wheres->{"$formulavar.ParentFormulaID=$parentformulavar.ID"} = 1;
      my $res = GetIDForFormula
	(
	 Subroutine => 1,
	 Formula => $item,
	 ParentFormulaVar => $formulavar,
	 FormulaVars => $formulavars,
	 FormulaVarsIndex => $formulavarsindex,
	 ArgumentVars => $argumentvars,
	 ArgumentVarsIndex => $argumentvarsindex,
	 Wheres => $wheres,
	);
      if (! $res->{Success}) {
	print "ERROR getting id for subformula\n";
	print Dumper({Subformula => $item});
	return {
		Success => 0,
	       };
      }
      # add these to our own
      foreach my $statement (keys %{$res->{Wheres}}) {
	$wheres->{$statement} = 1;
      }
      foreach my $formulavar (keys %{$res->{FormulaVars}}) {
	$formulavars->{$formulavar} = 1;
      }
      $formulavarsindex = $res->{FormulaVarsIndex};
      foreach my $argumentvar (keys %{$res->{ArgumentVars}}) {
	$argumentvars->{$argumentvar} = 1;
      }
      $argumentvarsindex = $res->{ArgumentVarsIndex};
    } elsif ($itemtype eq "GLOB") {
      # hrm...
    } else {
      # get a new argument
      my $argumentvar = "a$argumentvarsindex";
      ++$argumentvarsindex;
      $argumentvars->{$argumentvar} = 1;
      $wheres->{"$argumentvar.Value=".$mysql->Quote($item)} = 1;
      $wheres->{"$argumentvar.ParentFormulaID=$parentformulavar.ID"} = 1;
    }
  }

  if (! defined $args{Subroutine}) {
    # now if we are the top level, go ahead and generate the SQL and print it out
    print Dumper
      (
       {
	FormulaVars => $formulavars,
	ArgumentVars => $argumentvars,
	Wheres => $wheres,
       }
      ) if 0;
    my @vars;
    push @vars, "metadata m";
    foreach my $formulavar (sort keys %$formulavars) {
      push @vars, "formulae $formulavar";
    }
    foreach my $argumentvar (sort keys %$argumentvars) {
      push @vars, "arguments $argumentvar";
    }
    if (exists $args{Context}) {
      $wheres->{"m.ContextID=$contextid"} = 1;
    }
    my $statement = "select m.ID from ".join(", ",@vars)." where ".join(" and ",sort keys %$wheres);
    print $statement."\n";
    my $res = $mysql->Do
      (
       Statement => $statement,
      );
    return {
	    Success => 1,
	    Result => [keys %$res],
	   };
  } else {
    return {
	    Success => 1,
	    FormulaVars => $formulavars,
	    FormulaVarsIndex => $formulavarsindex,
	    ArgumentVars => $argumentvars,
	    ArgumentVarsIndex => $argumentvarsindex,
	    Wheres => $wheres,
	   };
  }
}
