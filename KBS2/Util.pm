package KBS2::Util;

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw (DumperQuote DumperQuote2 DeDumperQuote2 TermIsVariable
	      EmacsQuote PrologQuote PerlDataStructureToStringEmacs
	      PerlDataDedumperToStringEmacs FormulaToString
	      VariablesInFormula UnboundVariablesInFormulaP
	      PrettyPrintFormula PrettyPrintSubL GetItemForGLOB
	      CloseFormula StringToFormulae FormulaeToString
	      EmacsStringToFormulae NegateFormula Var
	      FormulaContainsSubformula GetAllReferringFormulae
	      ListVariablesInFormula DumperSingleQuote );

# ConvertInterlinguaVariableToEmacsString

use PerlLib::Util;

use Data::Dumper;
use Data::SExpression;
use Data::URIEncode qw(complex_to_query);
use String::ShellQuote;

our $debug = 0;

sub SwapInUndefs {
  my $formula = shift;
  if (defined $formula and
      ref $formula eq "ARRAY" and
      scalar @$formula) {
    my @retlist;
    foreach my $item (@$formula) {
      if (ref $item eq "GLOB") {
	my $dq = DumperQuote($item);
	if ($dq eq '\*::nil') {
	  push @retlist, undef;
	} else {
	  push @retlist, $item; # TermIsVariable($item);
	}
      } elsif (ref $item eq "ARRAY") {
	push @retlist, SwapInUndefs($item);
      }	else {
	push @retlist, $item;
      }
    }
    return \@retlist;
  }
}

sub EmacsQuote {
  my (%args) = @_;
  my $useqq = $Data::Dumper::Useqq;
  $Data::Dumper::Useqq = 1;
  my $thing = Dumper($args{Arg});
  print "Thing: $thing\n" if $debug;
  chomp $thing;
  if ($thing =~ /^\$VAR1 = (\[\s+)?(\"(.*)\")(\s+\])?;$/sm) {
    my $x = $3;
    # $x =~ s/\\\$/\$/g;
    print "X1: $x\n" if $debug;
    return '"'.$x.'"';
  } elsif ($thing =~ /^\$VAR1 = (.+);$/) {
    my $x = $1;
    # $x =~ s/\\\$/\$/g;
    print "X2: $x\n" if $debug;
    return '"'.$x.'"';
  }
  $Data::Dumper::Useqq = $useqq;
}

sub PrologQuoteOrig {
  my (%args) = @_;
  my $text = $args{Arg};
  my $quoted = shell_quote($text);
  $quoted =~ s/^'?/'/s;
  $quoted =~ s/'?$/'/s;
  return $quoted;
}

sub PrologQuote {
  my (%args) = @_;
  my $text = $args{Arg};
  my $quoted = shell_quote($text);
  $quoted =~ s/^'?/'/s;
  $quoted =~ s/'?$/'/s;
  $quoted =~ s/\'\\\'\'/''/sg;
  return $quoted;
}


sub CycPredicatify {
  my $item = shift;
  my $string = complex_to_query({data => $item});
  $string =~ s/^data=//;
  $string =~ s/\%/ZZZ/g;
  return '#$'.$string;
}

sub DumperQuote {
  my ($arg) = @_;
  my $useqq = $Data::Dumper::Useqq;
  $Data::Dumper::Useqq = 1;
  my $string = Dumper($arg);
  if ($string =~ /^\$VAR1 = (\[\s+)?(\'(.*)\')(\s+\])?;$/sm) {
    $Data::Dumper::Useqq = $useqq;
    return $3;
  } elsif ($string =~ /^\$VAR1 = (.+);/) {
    $Data::Dumper::Useqq = $useqq;
    return $1;
  } else {
    $Data::Dumper::Useqq = $useqq;
    return $string;
  }
}

sub TermIsVariable {
  my $arg = shift;
  # \*{'::?X'},
  if (DumperQuote($arg) =~ /^\\\*\{\'.*::(\?.+)\'\}$/) {
    return $1;
  } elsif (DumperQuote($arg) =~ /^\\\*\{\".*::(\?.+)\"\}$/) {
    return $1;
  }
}

sub PrettyPrintSubL {
  my (%args) = @_;
  require Manager::Misc::Light;
  my $m = Manager::Misc::Light->new;
  my $domain = $m->Parse
    (Contents => $args{String});
  foreach my $formula (@$domain) {
    
  }
}

sub GetItemForGLOB {
  my $arg = shift;
  my $string = DumperQuote($arg);
  # print Dumper($string);
  if ($string =~ /^\\\*\{\'::(.+)\'\}$/ or $string =~ /^\\\*\{\".+::(.+)\"\}$/) {
    my $item = $1;
    $item =~ s/^\$\$/\#\$/g;
    if ($item =~ /^\#\$/) {
      return $item;
    } elsif ($item =~ /^\?/) {
      return $item;
    } else {
      return '"'.$item.'"';
    }
  }
}

sub PerlDataDedumperToStringEmacs {
  my (%args) = @_;
  PerlDataStructureToStringEmacs
    (DataStructure => DeDumper($args{String}));
}

sub PerlDataStructureToStringEmacs {
  my (%args) = @_;
  my @list;
  my $arg = $args{DataStructure};
  my $string;
  if (ref $arg eq "ARRAY") {
    foreach my $item (@$arg) {
      push @list, PerlDataStructureToStringEmacs
	(
	 DataStructure => $item,
	);
    }
    $string = "(".join(" ",@list).")";
    return $string;
  } elsif (ref $arg eq "HASH") {
    # convert to an alist
    foreach my $key (keys %$arg) {
      push @list, "(".PerlDataStructureToStringEmacs
	(
	 DataStructure => $key,
	)." . ".
	  PerlDataStructureToStringEmacs
	    (
	     DataStructure => $arg->{$key},
	    ).
	      ")";
    }
    $string = "(".join(" ",@list).")";
    return $string;
  } elsif (ref $arg eq "GLOB") {
    # print Dumper($arg);
    # push @list, GetItemForGLOB($arg);
    # return TermIsVariable($arg);
    return PerlGlobToStringEmacs(Glob => $arg);
  } else {
    return EmacsQuote(Arg => $arg);
  }
}

sub FormulaToString {
  my (%args) = @_;
  if ($args{Type} eq "Emacs") {
    return FormulaToStringEmacs(%args);
  } elsif ($args{Type} eq "Perl") {
    return FormulaToStringPerl(%args);
  } elsif ($args{Type} eq "Cyc") {
    return FormulaToStringCyc(%args);
  }
}

sub VariablesInFormula {
  my (%args) = @_;
  my $r = $args{Formula};
  if (defined $r) {
    if (ref $r eq "ARRAY") {
      my $state = 0;
      foreach my $entry (@$r) {
	$state += VariablesInFormula(Formula => $entry);
      }
      return $state > 0;
    } elsif (ref $r eq "GLOB") {
      return defined TermIsVariable($r);
    } elsif ($r =~ /^\?/) {
      return 1;
    }
  } else {
    return 1;
  }
}

sub UnboundVariablesInFormulaP {
  my (%args) = @_;
  # FIXME: using VariablesInFormula does not handle formula that
  # have all bound variables
  return VariablesInFormula(Formula => $args{Formula})
}

sub PrettyPrintFormula {
  my (%args) = @_;
  require Manager::Misc::Light;
  my $string = FormulaToString
    (
     Type => "Emacs",
     Formula => $args{Formula},
    );
  $m = Manager::Misc::Light->new if ! $m;
  my $domain = $m->Parse
    (Contents => $string);
  return $m->PrettyGenerate
    (Structure => $domain->[0]);
}

sub CloseFormula {
  my (%args) = @_;
  # find all the unbound variables and bind them
  return $args{Formula};
}

sub StringToFormulae {		# V2
  my (%args) = @_;
  if ($args{FromType} eq "Emacs") {
    my $formula = EmacsStringToFormulae
      (
       String => $args{String},
      );
    return $formula;
  } elsif ($args{FromType} eq "Perl") {
    my $formula = PerlStringToFormulae
      (
       String => $args{String},
      );
    return $formula;
  } else {
    my $formula = StringToFormula
      (
       FromType => $args{FromType},
       String => $args{String},
      );
    # need to implement multiple formula
    return [$formula];
  }
}

sub StringToFormula {
  my (%args) = @_;
  my $string = $args{String};
  if ($args{FromType} eq "Emacs") {
    $formula = SexpStringToPerlFormula($string);
    return $formula;
  } elsif ($args{FromType} eq "Cyc") {
    $string =~ s/\#\$/\$\$/g;
    $formula = SexpStringToPerlFormula($string);
    return $formula;
  } elsif ($args{FromType} eq "Perl") {
    $VAR1 = undef;
    eval '$VAR1 = '.$search;
    my $list = $VAR1;
    $VAR1 = undef;
    return $list;
  }
}

sub SexpStringToPerlFormula {
  my $string = shift;
  if (! $ds) {
    $ds = Data::SExpression->new;
  }
  my $item = $ds->read($string);
  return SwapInUndefs($item);
}

sub FormulaeToString {
  my (%args) = @_;
  if ($args{Type} eq "Emacs") {
    my $res = FormulaeToStringEmacs
      (
       Formulae => $args{Formulae},
      );
    return $res;
  } elsif ($args{Type} eq "Perl") {
    return FormulaeToStringPerl
      (
       Formulae => $args{Formulae},
      );
  } else {
#     return {
# 	    Success => 0,
# 	    Reasons => {
# 			"No type given" => 1,
# 		       },
# 	   };
  }
}

sub FormulaeToStringEmacs {	# V2
  my (%args) = @_;
  my @list;
  foreach my $formula (@{$args{Formulae}}) {
    push @list, FormulaToStringEmacs
      (
       Formula => $formula,
      );
  }
  return join("\n",@list);
}

sub FormulaToStringEmacs {
  my (%args) = @_;
  my @list;
  foreach my $arg (@{$args{Formula}}) {
    if (ref $arg eq "ARRAY") {
      push @list, FormulaToStringEmacs
	(
	 Formula => $arg,
	);
    } else {
      if (ref $arg eq "GLOB") {
	push @list, PerlGlobToStringEmacs(Glob => $arg);
      } else {
	push @list, EmacsQuote(Arg => $arg);
      }
    }
  }
  my $string = "(".join(" ",@list).")";
  return $string;
}

sub PerlGlobToStringEmacs {
  my (%args) = @_;
  my $var = TermIsVariable($args{Glob});
  $var =~ s/^\?/var-/;
  return $var;
}

sub FormulaeToStringPerl {
  my (%args) = @_;
  my $res = DumperQuote2($args{Formulae});
  return $res;
}

sub EmacsStringToFormulae {
  my (%args) = @_;
  my $string = "(".$args{String}.")";
  if (! $ds) {
    $ds = Data::SExpression->new;
  }
  my $item = $ds->read($string);
  if (0) {
    return AlterVariables
      (Item => $item);
  } else {
    my $item1 = AlterConses
      (Item => $item);
    return AlterVariables
      (Item => $item1);
  }
}

sub PerlStringToFormulae {
  my (%args) = @_;
  my $item = DeDumperQuote2($args{String});
  # print Dumper({TIEM => $item});
  return $item;
}


sub AlterConses {
  my (%args) = @_;
  $formula = $args{Item};
  if (defined $formula and
      ref $formula eq "ARRAY" and
      scalar @$formula) {
    my @retlist;
    foreach my $item (@$formula) {
      if (ref $item eq "ARRAY") {
	push @retlist, AlterConses(Item => $item);
      }	elsif (ref $item eq "Data::SExpression::Cons") {
	push @retlist, [$item->{car}, $item->{cdr}];
      } else {
	push @retlist, $item;
      }
    }
    return \@retlist;
  }
}


sub AlterVariables {
  my (%args) = @_;
  $formula = $args{Item};
  if (defined $formula and
      ref $formula eq "ARRAY" and
      scalar @$formula) {
    my @retlist;
    foreach my $item (@$formula) {
      if (ref $item eq "GLOB") {
	my $dq = DumperQuote($item);
	if ($dq eq '\*::nil') {
	  push @retlist, undef;
	} else {
	  push @retlist, ConvertEmacsStringVariableToInterlinguaVariable(Item => $item);
	}
      } elsif (ref $item eq "ARRAY") {
	push @retlist, AlterVariables(Item => $item);
      }	else {
	push @retlist, $item;
      }
    }
    return \@retlist;
  }
}

sub ConvertEmacsStringVariableToInterlinguaVariable {
  my (%args) = @_;
  my $arg = $args{Item};
  if (DumperQuote($arg) =~ /^\\\*\{\'.*::((\?|var-)(.+))\'\}$/) {
    return \*{"::?$3"};
  } elsif (DumperQuote($arg) =~ /^\\\*\{\".*::((\?|var-)(.+))\"\}$/) {
    return \*{"::?$3"};
  }
}

# sub ConvertInterlinguaVariableToEmacsString {
#   my (%args) = @_;
#   my $arg = $args{Item};
#   PerlGlobToStringEmacs
# }

sub DumperQuote2Orig {
  my ($arg) = @_;
  my $previoususeqq = $Data::Dumper::Useqq;
  my $previouspurity = $Data::Dumper::Purity;
  my $previousdeepcopy = $Data::Dumper::Deepcopy;
  Data::Dumper->Useqq(1);
  Data::Dumper->Purity(1);
  Data::Dumper->Deepcopy(1);
  my $string = Dumper($arg);
  if ($string =~ /^\$VAR1 = (.+);/sm) {
    Data::Dumper->Useqq($previoususeqq);
    Data::Dumper->Purity($previouspurity);
    Data::Dumper->Deepcopy($previousdeepcopy);
    return $1;
  } else {
    Data::Dumper->Useqq($previoususeqq);
    Data::Dumper->Purity($previouspurity);
    Data::Dumper->Deepcopy($previousdeepcopy);
    return $string;
  }
}

sub DumperQuote2 {
  my ($arg) = @_;
  my $previoususeqq = $Data::Dumper::Useqq;
  my $previouspurity = $Data::Dumper::Purity;
  my $previousdeepcopy = $Data::Dumper::Deepcopy;
  $Data::Dumper::Useqq = 1;
  $Data::Dumper::Purity = 1;
  $Data::Dumper::Deepcopy = 1;
  my $string = Dumper($arg);
  Data::Dumper->Useqq($previoususeqq);
  Data::Dumper->Purity($previouspurity);
  Data::Dumper->Deepcopy($previousdeepcopy);
  if ($string =~ /^\$VAR1 = (.+);/sm) {
    return $1;
  } else {
    return $string;
  }
}


sub DeDumperQuote2 {
  my ($arg) = @_;
  my $item = '$VAR1 = '.$arg.';';
  my $it;
  $VAR1 = undef;
  eval $item;
  eval $item;
  $it = $VAR1;
  $VAR1 = undef;
  return $it;
}

sub NegateFormula {
  my (%args) = @_;
  if ($args{Formula}->[0] eq "not") {
    return $args{Formula}->[1];
  } else {
    return ["not", $args{Formula}];
  }
}

sub Var {
  my $variablename = shift;
  return \*{"::$variablename"};
}

sub GetAllReferringFormulae {
  my (%args) = @_;
  # for now just get all of them and find the matches
  my $formulae = $args{Formulae};
  my @matches;
  foreach my $formula (@$formulae) {
    if (FormulaContainsSubformula
	(
	 Formula => $formula,
	 Subformula => $args{Subformula},
	)) {
      push @matches, $formula;
    }
  }
  return \@matches;
}

sub FormulaContainsSubformula {
  my (%args) = @_;
  my $subformula = Dumper($args{Subformula});
  foreach my $part (@{$args{Formula}}) {
    if (Dumper($part) eq $subformula) {
      return 1;
    } else {
      my $ref = ref $part;
      if ($ref eq "ARRAY") {
	if (FormulaContainsSubformula
	    (
	     Formula => $part,
	     Subformula => $args{Subformula},
	    )) {
	  return 1;
	}
      }
    }
  }
}

sub ListVariablesInFormula {
  my (%args) = @_;
  my $r = $args{Formula};
  my @variables;
  if (defined $r) {
    if (ref $r eq "ARRAY") {
      foreach my $entry (@$r) {
	push @variables, @{ListVariablesInFormula(Formula => $entry)};
      }
    } elsif (ref $r eq "GLOB") {
      push @variables, $r;
    } elsif ($r =~ /^\?/) {
      # do nothing
    }
  }
  return \@variables;
}

sub DumperSingleQuote {
  my ($arg) = @_;
  my $useqq = $Data::Dumper::Useqq;
  $Data::Dumper::Useqq = 0;
  my $string = Dumper($arg);
  if ($string =~ /^\$VAR1 = (\[\s+)?(\'(.*)\')(\s+\])?;$/sm) {
    $Data::Dumper::Useqq = $useqq;
    return $2;
  } elsif ($string =~ /^\$VAR1 = (.+);/) {
    $Data::Dumper::Useqq = $useqq;
    # FIXME: what to do here
    # return $1;
  } else {
    $Data::Dumper::Useqq = $useqq;
    # FIXME: what to do here
    # return $string;
  }
}

1;
