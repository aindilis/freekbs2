package KBS2::Store::Collection;

use KBS2::Util;
use KBS2::Util::SZSProblemStatusOntology;
use Manager::Dialog qw(ApproveStrongly);
use PerlLib::Collection;
use Sayer;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMySQL Context Database Debug MySayer MyReasoner
	MyProblemOntology /

  ];

sub init {			# V2
  my ($self,%args) = @_;
  $self->Debug($args{Debug} || $UNIVERSAL::debug);
  $self->Context
    ($args{Context} || "default");
  $self->Database
    ($args{Database} || "freekbs2");
  $self->MyMySQL
    (PerlLib::MySQL->new
     (
      DBName => $self->Database,
      Debug => $self->Debug,
     ));
  $self->MyMySQL->Debug($self->Debug);
  $self->MyMySQL->GetDatabaseInformation;
  my $reasoner = $args{Reasoner} || "Vampire";
  my $dir = "$UNIVERSAL::systemdir/KBS2/Reasoner";
  my $name = $reasoner;
  $name =~ s/::/\//g;
  require "$dir/$name.pm";
  $self->MyReasoner
    ("KBS2::Reasoner::$reasoner"->new
     (
      Debug => $self->Debug,
     ));
  $self->MyReasoner->StartServer;
  $self->MyProblemOntology
    (KBS2::Util::SZSProblemStatusOntology->new());
}

sub Assert {			# V2
  my ($self,%args) = @_;
  if ($args{Formula}) {
    my $context = $args{Context} || $self->Context;
    my $queryresults = $self->Query
      (
       Type => "Can Assert",
       Formula => $args{Formula},
       Context => $context,
       DontAnnounce => 1,
      );
    # if it is not yet asserted and if it not inconsistent
    print Dumper({QueryResults => $queryresults}) if $self->Debug;
    if ($queryresults->{CanAssert}) {
      # break this down into the individual subformulas and assert them first
      my $res = $self->AssertFormula
	(
	 ParentFormulaID => -1,
	 ArgumentID => -1,
	 Formula => $args{Formula},
	 Context => $context,
	 Asserter => $args{Asserter},
	 UseSayer => $args{UseSayer},
	);
      if ($res->{Success}) {
	State("assert",$args{Formula});
	return {
		Success => 1,
	       };
      } else {

      }
    } else {
      # deal with this in the future
      return {
	      Success => 0,
	      Reasons => $queryresults->{Reasons},
	     };
    }
  } else {
    return {
	    Success => 0,
	    Reasons => {
			"Formula is Empty",
		       },
	   };
  }
}

sub AssertFormula {		# V2
  my ($self,%args) = @_;

  # add the formulae entry
  $self->MyMySQL->Insert
    (
     Table => "formulae",
     Values => [
		undef,			# argument id
		$args{ParentFormulaID},	# key becomes parent formula id
		$args{ArgumentID} || "NULL", # argument id
		scalar @{$args{Formula}},    # arity
	       ],
    );
  my $formulaid = $self->MyMySQL->InsertID
    (Table => "formulae");

  # now, foreach child
  my $i = 0;
  foreach my $item (@{$args{Formula}}) {
    my $itemtype = ref $item;
    if ($itemtype eq "ARRAY") {
      # this is a subformula
      my $res = $self->AssertFormula
	(
	 ParentFormulaID => $formulaid,
	 ArgumentID => undef,
	 Formula => $item,
	 UseSayer => $args{UseSayer},
	);

      if (! $res->{Success}) {
	print "ERROR asserting subformula\n";
	print Dumper({Subformula => $item});
	return {
		Success => 0,
	       };
      }
      my $subformulaid = $res->{FormulaID};

      # do we need to add an arguments entry for this for this item? I believe we do
      $self->MyMySQL->Insert
	(
	 Table => "arguments",
	 Values => [
		    undef,	# id
		    $formulaid,	# parent formula id
		    "formula",
		    $i++,	   # key
		    $subformulaid, # value, which in this case is
				   # the formula id
		   ],
	);
      my $argumentid = $self->MyMySQL->InsertID
	(Table => "arguments");

      # now update the for
      $self->MyMySQL->Do
	(Statement => "update formulae set ArgumentID='".$argumentid."' where ID='".$subformulaid."';");
    } elsif ($itemtype eq "GLOB") {
      my $value = GetItemForGLOB($item);
      my $valuetype = "variable";
      $self->MyMySQL->Insert
	(
	 Table => "arguments",
	 Values => [
		    undef,	# argument id
		    $formulaid,	# parent formula id
		    $valuetype,	# value type
		    $i++,	# key
		    $value,	# value
		   ],
	);
    } else {
      # just add this to the database for now, can add to Sayer later
      my $value = $item;
      my $valuetype = "string";
      if ($args{UseSayer}) {
	$self->StartSayer;
	$value = $self->Sayer->AddData
	  (Data => $item);
	$valuetype = "sayer";
      }
      $self->MyMySQL->Insert
	(
	 Table => "arguments",
	 Values => [
		    undef,	# argument id
		    $formulaid,	# parent formula id
		    $valuetype,	# value type
		    $i++,	# key
		    $value,	# value
		   ],
	);
    }
  }

  if ($args{ParentFormulaID} == -1) {
    # add the context data
    my $contextid = $self->GetContextID(Context => $args{Context});
    my $asserterid = $self->GetAsserterID(Asserter => $args{Asserter});

    # add the metadata entry
    $self->MyMySQL->Insert
      (
       Table => "metadata",
       Values => [
		  undef,	# id
		  $formulaid,	# root formula id
		  $contextid,	# context id
		  $asserterid,	# asserter id
		  'Now()',	# date
		 ],
      );
    # my $metadataid = $self->MyMySQL->InsertID
    # (Table => "metadata");
  }
  return {
	  Success => 1,
	  FormulaID => $formulaid,
	 };
}

sub GetContextID {		# V2
  my ($self,%args) = @_;
  my $quotedcontext = $self->MyMySQL->Quote
    ($args{Context});
  my $res = $self->MyMySQL->Do
    (Statement => "select * from contexts where Context=$quotedcontext");
  my $count = scalar keys %$res;
  if (! $count) {
    # assert it, return ID
    $self->MyMySQL->Insert
      (
       Table => "contexts",
       Values => [
		  undef,	  # id
		  $args{Context}, # context
		 ],
      );
    my $contextid = $self->MyMySQL->InsertID
      (Table => "contexts");
    return $contextid;
  } elsif ($count > 1) {
    print "WARNING, multiple matches for context\n";
    print Dumper({Context => $args{Context}});
    return -1; 			# FIX ME
  } else {
    my @keys = keys %$res;
    my $key = shift @keys;
    return $key;
  }
}

sub GetAsserterID {		# V2
  my ($self,%args) = @_;
  my $quotedasserter = $self->MyMySQL->Quote
    ($args{Asserter});
  my $res = $self->MyMySQL->Do
    (Statement => "select * from asserters where Asserter=$quotedasserter");
  my $count = scalar keys %$res;
  if (! $count) {
    # assert it, return ID
    $self->MyMySQL->Insert
      (
       Table => "asserters",
       Values => [
		  undef,	   # id
		  $args{Asserter}, # asserter
		 ],
      );
    my $asserterid = $self->MyMySQL->InsertID
      (Table => "asserters");
    return $asserterid;
  } elsif ($count > 1) {
    print "WARNING, multiple matches for asserter\n";
    print Dumper({Asserter => $args{Asserter}});
    return -1; 			# FIX ME
  } else {
    my @keys = keys %$res;
    my $key = shift @keys;
    return $key;
  }
}

sub State {			# V2
  my ($disp,$formula) = @_;
  print "$disp: ".FormulaToString
    (
     Formula => $formula,
     Type => "Emacs",
    )."\n";
}

sub Query {
  my ($self,%args) = @_;
  if (! $args{DontAnnounce}) {
    State("query",$args{Formula});
  }
  my $returnargs = {};
  my $formula = $args{Formula};
  my $context = $args{Context} || $self->Context;
  my $theory = $args{Theory} || $self->AllAssertedKnowledge
    (
     Context => $context,
    );
  my $type = $args{Type};

  # print Dumper({Theory => $theory});

  # my $tmp = $self->NonTrivialFormula(Formula => $formula);
  # print Dumper({TMP => $tmp});
  # return if $tmp;

  if ($type eq "Can Assert") {
    # whether it is already asserted in the axioms
    # whether it already follows from the theory
    # whether it is independent of the theory
    # whether it is inconsistent with the theory
    # whether we can not determine whether it follows
    # check if it it follows
    my $res2 = $self->Query
      (
       DontAnnounce => 1,
       Type => "System Status",
       Formula => $formula,
       Theory => $theory,
       Context => $context,
      );
    my $res3 = $self->Query
      (
       DontAnnounce => 1,
       Type => "System Status",
       Formula => NegateFormula(Formula => $formula),
       Theory => $theory,
       Context => $context,
      );

    # now compute the can assert, the success, and the reason
    # arguments
    if ($res2->{InconsistentAxioms}) {
      $returnargs->{Success} = 0; # meaning we need to fix the axioms
      $returnargs->{Reasons}->{InconsistentAxioms} = 1;
      return $returnargs;
    } else {
      # figure out based on the responses of P and Not P whether we can assert

      my $pcode = $res2->{Type} eq "_Already Asserted" ? "_Already Asserted" : $res2->{Results}->[-1]->{Result}->{Type};
      my $notpcode = $res3->{Type} eq "_Already Asserted" ? "_Already Asserted" : $res3->{Results}->[-1]->{Result}->{Type};
      my $p_canassert = $self->MyProblemOntology->CanAssert->{$pcode}->{CanAssert};
      my $notp_canassert = $self->MyProblemOntology->CanAssert->{$notpcode}->{CanAssert};
      my $p_truthvalue = $self->MyProblemOntology->TruthValue->{$pcode}->{TruthValue};
      my $notp_truthvalue = $self->MyProblemOntology->TruthValue->{$notpcode}->{TruthValue};

      print Dumper
	({
	  PCode => $pcode,
	  NotPCode => $notpcode,
	  P_Canassert => $p_canassert,
	  NotP_Canassert => $notp_canassert,
	  P_TruthValue => $p_truthvalue,
	  NotP_TruthValue => $notp_truthvalue,
	 }) if $self->Debug;

      # let's just check for some quick reasons not to assert
      my $errors = {};
      if ($pcode eq "_Already Asserted") {
	$errors->{"PCode eq '_Already Asserted': the formula is already asserted, therefore it cannot be asserted again"} = 1;
      }
      if ($notpcode eq "_Already Asserted") {
	$errors->{"NotPCode eq '_Already Asserted': the negation is already asserted, therefore it cannot be true nor asserted"} = 1;
      }
      if (defined $p_canassert and ! $p_canassert) {
	$errors->{"P_Canassert = 0: the system says that for logical/system reasons, it cannot be asserted"} = 1;
      }
      if ($notp_truthvalue eq "true") {
	$errors->{"NotP_TruthValue eq 'true': it's negation is true, don't assert"} = 1;
      }
      if (scalar keys %$errors) {
	return {
		Success => 1,
		CanAssert => 0,
		Reasons => $errors,
	       };
      }

      # now check whether the system says anything in support of it
      # being asserted
      my $flags = {};
      if ($p_canassert == 1) {
	$flags->{"P_Canassert = 1: the system says that for logical/system reasons, it can be asserted"} = 1;
      }
      if ($p_truthvalue eq "true") {
	$flags->{"P_TruthValue eq 'true': it is true, and P_Canassert is not 0, so probably can assert"} = 1;
      }
      if (
          $p_truthvalue eq "unknown" and
          ! defined $p_canassert and
          $notp_truthvalue eq "unknown" and
          $pcode eq "Unknown" and
          $notpcode eq "Unknown" and
          ! defined $notp_canassert
	 ) {
	$flags->{"Nothing is known about the statement or its negation"} = 1;
      }
      if (scalar keys %$flags) {
	# go ahead and assert for now cause we can't do any better
	# (unless we are being strictly careful)
	return {
		Success => 1,
		CanAssert => 1,
		Reasons => $flags,
	       };
      } else {
	# go ahead and assert for now cause we can't do any better
	# (unless we are being strictly careful)
	return {
		Success => 0,
		CanAssert => 0,
		Reasons => {
			    "Not enough is known to assert" => 1,
			   },
	       };
      }
    }
  } elsif ($type eq "System Status" or $type eq "Exists") {
    # shouldn't we check whether it is an assertion in the KB first?

    # need to figure out whether it already is asserted
    # do a search for the formula in the database
    my $res = $self->SearchForExistingFormula
      (
       Formula => $formula,
       Theory => $theory,
      );
    if (! $res->{Success}) {
      return {
	      Success => 0,
	      Reasons => $res->{Reasons},
	     };
    } else {
      if ($res->{"Already Asserted"}) { # Already been asserted
	# now we need to return that it cannot assert it
	$returnargs->{Type} = "_Already Asserted";
	$returnargs->{Success} = 1; # meaning that the answer was obtained
	# because it is asserted then it automatically follows, but have
	$returnargs->{TruthValue} = "true";
      } else {
	# okay send the query to the reasoner
	my $res2 = $self->MyReasoner->Query
	  (
	   Theory => $theory,
	   Formula => $formula,
	   Context => $context,
	  );

	# 	# should probably add information as to whether the axioms are inconsistent, extracted from iterating over the items
	# 	foreach my $result (@{$res2->{Results}}) {
	# 	  if ($result->{Result}->{Type} eq "ContradictoryAxioms") {
	# 	    $res2->{ContradictoryAxioms} = 1;
	# 	  }
	# 	}

	my $tmphash = $res2->{Results}->[-1]->{Result};
	foreach my $key (keys %$tmphash) {
	  if (exists $res2->{$key}) {
	    print "ERROR: (1) overwriting key <<<$key>>>\n";
	  } else {
	    $res2->{$key} = $tmphash->{$key};
	  }
	}

	# try to add something simple in here about whether the item is
	# true

	$returnargs->{TruthValue} = $self->MyProblemOntology->TruthValue->{$res2->{Type}}->{TruthValue};
	$res2->{Success} = $self->MyProblemOntology->TruthValue->{$res->{Type}}->{Success} || 1;

	foreach my $key (keys %$res2) {
	  if (exists $returnargs->{$key}) {
	    print "ERROR: (2) overwriting key <<<$key>>>\n";
	  }
	  $returnargs->{$key} = $res2->{$key};
	}
      }
    }
    return $returnargs;
  } elsif ($type eq "Models") {

    # models wants a set of models of the formula, that is, values for
    # all the variables in the formula.  Figure out how to do that,
    # for now, return nothing

    # okay send the query to the reasoner
    my $res2 = $self->MyReasoner->Query
      (
       Attributes => {
		      Models => 1,
		     },
       Theory => $theory,
       Formula => $formula,
       Context => $context,
      );

    print Dumper({Res2 => $res2}) if $self->Debug;

    # need to fix this, not theorem, should be model

    if (exists $args{Flags} and ! $args{Flags}->{Quiet}) {
      my $tmphash = $res2->{Results}->[-1]->{Result};
      foreach my $key (keys %$tmphash) {
	if (exists $res2->{$key}) {
	  print "ERROR: (3) overwriting key <<<$key>>>\n";
	} else {
	  print "Key $key\n" if $self->Debug;
	  $returnargs->{$key} = $self->Copy(Item => $tmphash->{$key});
	}
      }

      foreach my $key (keys %$res2) {
	if (exists $returnargs->{$key}) {
	  print "ERROR: (4) overwriting key <<<$key>>>\n";
	} else {
	  print "Key2 $key\n" if $self->Debug;
	  $returnargs->{$key} = $self->Copy(Item => $res2->{$key});
	}
      }
    }

    my @retval;
    # # model(((?BAISC . "find more stuff")) ((?BAISC . "Do this or that")) )
    foreach my $result (@{$res2->{Results}}) {
      if (defined $result->{Models}) {
	my @result;
	foreach my $model (@{$result->{Models}}) {
	  my @binding;
	  foreach my $bindings (@{$model->{BindingSet}}) {
	    foreach my $key (keys %$bindings) {
	      # FIXME Move this to the Vampire modules, not the MySQL
	      my $res5 = $UNIVERSAL::kbs2->MyImportExport->Convert
		(
		 Input => "(".$bindings->{$key}.")",
		 InputType => "KIF String",
		 OutputType => "Interlingua",
		);
	      if ($res5->{Success}) {
		push @binding, [
				\*{"::$key"},
				# FreeKBS2::Special::ConsPeriod->new(),
				$res5->{Output}->[0]->[0],
			       ];
	      } else {
		print "ERROR!\n";
	      }
	    }
	  }
	  push @result, \@binding;
	}
	push @retval, \@result;
      }
    }

    if (exists $args{Flags} and ! $args{Flags}->{Quiet}) {
      $returnargs->{Bindings} = \@retval;
    }

    # figure out here if we want cycl like querying

    if (exists $args{Flags} and $args{Flags}->{OutputType} eq "CycL String") {
      # need to convert the models to a cycl string
      my $res4 = $UNIVERSAL::kbs2->MyImportExport->Convert
	(
	 Input => \@retval,
	 InputType => "Interlingua",
	 OutputType => "Emacs String",
	);
      if ($res4->{Success}) {
	$returnargs->{CycL} = $res4->{Output};
      }
    }
    return $returnargs;
  } elsif ($type eq "GetID") {
    my $res3 = $self->GetIDForFormula
      (Formula => $formula);
    return $res3;
  }
}

sub NonTrivialFormula {	     # V2 (not sure if this is correct though)
  my ($self,%args) = @_;
  if (defined $args{Formula} and
      # ??? ref $args{Formula} eq "HASH" and
      ref $args{Formula} eq "ARRAY" and
      scalar @{$args{Formula}}) {
    my $ok = 0;
    foreach my $arg (@{$args{Formula}}) {
      if (defined $arg and
	  ref $arg eq "ARRAY" and
	  scalar @$arg) {
	$ok = 1 if $self->NonTrivialFormula
	  (Formula => $arg);
      } else {
	$ok = 1 if defined $arg;
      }
    }
    return $ok;
  }
}

sub AllAssertedKnowledge {	# V2
  my ($self,%args) = @_;
  my @knowledge;
  my $statement;
  my @conditions;
  if (exists $args{Context}) {
    push @conditions, "ContextID = ".$self->GetContextID(Context => $args{Context}); # Add error checking later
  }
  if (exists $args{Asserter}) {
    push @conditions, "AsserterID = ".$self->GetAsserterID(Asserter => $args{Asserter}); # Add error checking later
  }
  if (defined $args{Date}) {
    push @conditions, "Date ".$args{Date};
  }
  if (scalar @conditions > 0) {
    # now select all the formulaids that meet these criteria
    $statement = "select distinct FormulaID from metadata where ".join(" and ",@conditions);
  } else {
    $statement = "select distinct FormulaID from metadata";
  }
  my $res = $self->MyMySQL->Do
    (
     Statement => $statement,
     Array => 1,
    );
  my $ids1 = {};
  foreach my $entry 
    (@{$res}) {
    $ids1->{$entry->[0]}++;
  }
  my $ids = {};
  if ($args{Search}) {
    foreach my $id (@{$self->AllAssertedKnowledgeOriginal
			(
			 IDsOnly => 1,
			 Search => $args{Search},
			)}) {
      if (exists $ids1->{$id}) {
	$ids->{$id}++;
      }
    }
  } else {
    $ids = $ids1;
  }
  if ($args{IDsOnly}) {
    return [keys %$ids],
  } else {
    foreach my $id (keys %$ids) {
      push @knowledge, $self->Retrieve(ID => $id);
    }
    return \@knowledge;
  }
}

sub AllAssertedKnowledgeOriginal { # V2
  my ($self,%args) = @_;
  my @knowledge;
  my @ids;
  my $statement;
  if (defined $args{Search}) {
    my $quoted = $self->MyMySQL->Quote($args{Search});
    $statement = "select distinct ParentFormulaID from arguments where (ValueType='string' or ValueType='sayer') and Value=$quoted;";
    my $matchingrootformulaids = {};
    foreach my $entry 
      (@{$self->MyMySQL->Do
	   (
	    Statement => $statement,
	    Array => 1,
	   )}) {
      $matchingrootformulaids->{$self->GetRootFormula(ID => $entry->[0])}++;
    }
    foreach my $rootformulaid (keys %$matchingrootformulaids) {
      if ($args{IDsOnly}) {
	push @ids, $rootformulaid;
      } else {
	push @knowledge, $self->Retrieve(ID => $rootformulaid);
      }
    }
  } else {
    $statement = "select distinct ID from formulae where ParentFormulaID=-1";
    foreach my $entry 
      (@{$self->MyMySQL->Do
	   (
	    Statement => $statement,
	    Array => 1,
	   )}) {
      if ($args{IDsOnly}) {
	push @ids, $entry->[0];
      } else {
	push @knowledge, $self->Retrieve(ID => $entry->[0]);
      }
    }
  }
  if ($args{IDsOnly}) {
    return \@ids;
  } else {
    return \@knowledge;
  }
}

sub Retrieve {			# V2
  my ($self,%args) = @_;
  print Dumper({RetrieveArgs => \%args}) if $self->Debug;
  # my $r1 = $self->MyMySQL->Do(Statement => "select * from tuples where ID=$args{ID}");
  my $r2 = $self->MyMySQL->Do(Statement => "select * from arguments where ParentFormulaID=$args{ID}");
  # now reconstruct it
  my @rec;
  foreach my $aid (keys %$r2) {
    if ($r2->{$aid}->{ValueType} eq "formula") {
      $rec[$r2->{$aid}->{KeyID}] = $self->Retrieve
	(ID => $r2->{$aid}->{Value});
    } else {
      $rec[$r2->{$aid}->{KeyID}] = $r2->{$aid}->{Value};
    }
  }
  return \@rec;
}

sub UnAssert {			# V2
  my ($self,%args) = @_;
  print Dumper({UnassertArgs => \%args}) if $self->Debug;
  # make sure that there are no undefs in here
  if (VariablesInFormula(Formula => $args{Formula})) {
    print "ERROR: unassert too general, eliminated nil/undefs\n";
    print "Proceeding with experimental results\n";
    my $res = $self->Query
      (
       DontAnnounce => 1,
       Type => "Models",
       Formula => $args{Formula},
       Context => $args{Context},
      );

    # okay, we need to convert from a list of bindings to a list of
    # Formula IDs.  This means translating bindings into formula,
    # checking if the formula exists...  hrm

    print Dumper({ModelsRes => $res});
    foreach my $formula (@{$res->{Models}->{Formulae}}) {
      my $res3 = $self->GetIDForFormula
	(Formula => $formula);
      if ($res3->{Success}) {
	my $id = $res3->{ID};
	print "Remove $id\n";
	# $self->Remove(ID => $id);
      } else {
	print "No id for formula ".Dumper($formula)."\n\n";
      }
    }
  } else {
    $self->GetIDForFormula
      (
       Formula => $args{Formula},
      );
  }
}

sub Remove {			# V2
  my ($self,%args) = @_;
  # if the id is not a root formula id, protest
  my $isrootformula = $self->RootFormulaP(ID => $args{ID});
  my $formulacontents;
  if ($isrootformula) {
    $formulacontents = $self->Retrieve(ID => $args{ID});
  } else {
    if (! exists $args{RemoveSubformula}) {
      print "ERROR: $args{ID} is not the ID of a root formula\n";
      return 0;
    }
  }

  # basically
  # foreach argument that has parentformulaid as the formula id {
  my $res = $self->MyMySQL->Do
    (Statement => "select * from arguments where ParentFormulaID = $args{ID}");
  foreach my $argumentid (keys %$res) {
    #  if valuetype is formula
    if ($res->{$argumentid}->{ValueType} eq "formula") {
      # delete the formula that has the ID that is in Value
      $self->Remove
	(
	 RemoveSubformula => 1,
	 ID => $res->{$argumentid}->{Value},
	);
    }
    #  remove the argument by its id
    $self->MyMySQL->Do(Statement => "delete from arguments where ID=$argumentid");
  }

  # take the formula id, remove the formula with that id from formulae
  $self->MyMySQL->Do(Statement => "delete from formulae where ID=$args{ID}");
  if ($isrootformula) {
    # remove from the metadata
    $self->MyMySQL->Do(Statement => "delete from metadata where FormulaID=$args{ID}");
    # execute hooks for this formula
    State("unassert",$formulacontents);
  }
}

sub StartSayer {		# V2
  my ($self,%args) = @_;
  $self->MySayer
    ($args{Sayer} ||
     Sayer->new
     (DBName => $args{DBName} || "sayer_freekbs2"));
}

sub RootFormulaP {		# V2
  my ($self,%args) = @_;
  # true iff the root formula ID of ID is ID (itself)
  return $args{ID} == $self->GetRootFormula(ID => $args{ID});
}

sub GetRootFormula {		# V2
  my ($self,%args) = @_;
  # take the id of a formula, and traverse upwards until the root formula is obtained
  my $id = $args{ID};
  # get the partent of this ID
  if ($id == -1) {
    print "ERROR: asked for root formula with a formula ID of -1\n";
  } else {
    my $parentformulaid = $self->MyMySQL->Do
      (
       Statement => "select ParentFormulaID from formulae where ID=$id",
       Array => 1,
      )->[0]->[0];
    if ($parentformulaid == -1) {
      # that means that $id is the root formula ID
      return $id;
    } else {
      return $self->GetRootFormula
	(ID => $parentformulaid);
    }
  }
}

sub Clean {			# V2
  my ($self,%args) = @_;
  # for debugging purposes, clean the entire system
  if (ApproveStrongly
      ("TRUNCATE ALL THE TABLES IN THE ENTIRE FREEKBS2 DATABASE?")) {
    foreach my $table (qw(metadata formulae arguments)) {
      $self->MyMySQL->Do(Statement => "truncate $table;");
    }
  }
}

sub SearchForExistingFormula {	# V2
  my ($self,%args) = @_;
  # iterate over all formulas, check for equivalence (at least till we have a better way to do this....)
  my $formuladump = $self->NormalizeVariablesAndPrint
    (Formula => $args{Formula});
  foreach my $formula (@{$args{Theory}}) {
    if ($formuladump eq $self->NormalizeVariablesAndPrint
	(Formula => $formula)) {
      return {
	      "Success" => 1,
	      "Already Asserted" => 1,
	     }
    }
  }
  return {
	  "Success" => 1,
	  "Already Asserted" => 0,
	 };
}

sub RestartReasoner {
  my ($self,%args) = @_;
  $self->MyReasoner->RestartServer();
}

sub NormalizeVariablesAndPrint {
  my ($self,%args) = @_;
  # replace the items of all their variables
  # FIX ME, just dumping right now
  return Dumper($args{Formula});
}

sub Copy {
  my ($self,%args) = @_;
  my $item = $args{Item};
  my $ref = ref $item;
  if ($ref eq "ARRAY") {
    my @list;
    foreach my $arg (@$item) {
      push @list, $self->Copy
	(Item => $arg);
    }
    return \@list;
  } elsif ($ref eq "HASH") {
    my %hash;
    foreach my $key (keys %$item) {
      my $key2 = $key;
      $hash{$key2} = $self->Copy
	(Item => $item->{$key});
    }
    return \%hash;
  } else {
    my $item2 = $item;
    return $item2;
  }
}

sub ClearContext {
  my ($self,%args) = @_;
  my $ids = $self->AllAssertedKnowledge
    (
     IDsOnly => 1,
     Context => $args{Context},
    );
  print Dumper({IDS => $ids});
  foreach my $id (@$ids) {
    $self->Remove
      (
       ID => $id,
      );
  }
}

sub GetIDForFormula {
  my ($self,%args) = @_;
  return {
	  Success => 0,
	  Reasons => {
		      "not yet implemented" => 1,
		     },
	 };
}

1;
