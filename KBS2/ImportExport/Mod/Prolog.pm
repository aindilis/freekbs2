package KBS2::ImportExport::Mod::Prolog;

print STDERR "warning: Prolog import export not fully functional\n";

use KBS2::ImportExport;
use KBS2::Util;
use Language::Prolog::Yaswi ':query';
use PerlLib::SwissArmyKnife;
use PerlLib::Util;

use AI::Prolog::Parser;
use Try::Tiny;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Types Debug ParentSelf /

  ];

sub init {
  my ($self,%args) = @_;
  $self->ParentSelf($args{Self});
  $self->Debug($args{Debug} || $UNIVERSAL::debug);
  $self->Types
    ({
      "Interlingua" => 1,
      "Prolog" => 1,
     });
}

sub Convert {
  my ($self,%args) = @_;
  if ($args{Input}) {
    if (exists $self->Types->{$args{InputType}}) {
      my $result = $self->ConvertToInterlingua
	(
	 Input => $args{Input},
	 InputType => $args{InputType},
	);
      if ($result->{Success}) {
	return $self->ConvertToOutputType
	  (
	   Interlingua => $result->{Interlingua},
	   OutputType => $args{OutputType},
	  );
      } else {
	return $result;
      }
    }
  }
}

sub ConvertToInterlingua {
  my ($self,%args) = @_;
  # takes as args InputType and Input
  if ($args{InputType} eq "Interlingua") {
    # it is already in interlingua format
    return {
	    Success => 1,
	    Interlingua => $args{Input},
	   };
  } elsif ($args{InputType} eq "Prolog") {
    my $res = $self->ConvertPrologToInterLingua
      (
       Prolog => $args{Input},
      );
    print Dumper({Res => $res}) if $self->Debug;
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Interlingua => $res->{Interlingua},
	     };
    } else {
      return $res;
    }
  } else {
    return {
	    Success => 0,
	    Reasons => {
			"Unknown InputType" => Dumper($args{InputType}),
		       }
	   };
  }
}

sub ConvertToOutputType {
  my ($self,%args) = @_;
  # takes as args OutputType and Interlingua
  if ($args{OutputType} eq "Interlingua") {
    return {
	    Success => 1,
	    Output => $args{Interlingua},
	   };
  } elsif ($args{OutputType} eq "Prolog") {
    my $res = $self->ConvertInterlinguaToProlog
      (
       Interlingua => $args{Interlingua},
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Output => $res->{Prolog},
	     };
    } else {
      return $res;
    }
  } else {
    return {
	    Success => 0,
	    Reasons => {
			"Unknown OutputType" => $args{OutputType},
		       }
	   };
  }
}


# sub ConvertPrologToInterLingua {
#   my ($self,%args) = @_;
#   my $order = {};
#   my $iorder = {};
#   my $reorder = {};

#   my $prolog1 = $args{Prolog};
#   my $i1 = 0;
#   my @statements1;
#   my @tmp1 = split /\)\.\n/, $prolog1;
#   $tmp1[-1] =~ s/\)\.$//;
#   foreach my $statement (@tmp1) {
#     $statement =~ s/^\s*//sg;
#     $statement .= ").";
#     push @statements1, $statement;
#     $order->{$statement} = $i1;
#     $iorder->{$i1} = $statement;
#     ++$i1;
#   }
#   my $prolog2 = join("\n",sort {$a cmp $b} @statements1);
#   my $i2 = 0;

#   my @tmp2 = split /\)\.\n/, $prolog2;
#   $tmp2[-1] =~ s/\)\.$//;
#   foreach my $statement (@tmp2) {
#     $statement =~ s/^\s*//sg;
#     $statement .= ").";
#     $reorder->{$order->{$statement}} = $i2++;
#   }

#   my $db = AI::Prolog::Parser->consult($prolog2);
#   my @all;
#   my $i = 1;

#   foreach my $key (sort keys %{$db->{'ht'}}) {
#     my $clause = $db->{'ht'}->{$key};
#     do {
#       my $item = $clause;
#       my @list;
#       do {
# 	push @list, $self->ConvertItemToKBS
# 	  (
# 	   Item => $item->term,
# 	  );
# 	$item = $item->next;
#       } while (defined $item);
#       my $length = scalar @list;
#       if ($length > 1) {
# 	my $entailment = shift @list;
# 	push @all,
# 	  (
# 	   ["implies",["and", @list], $entailment],
# 	  );
# 	++$i;
#       } elsif ($length == 1) {
# 	push @all, $list[0];
#       } else {
# 	print "WTF?\n";
#       }
#       $clause = $clause->{next_clause};
#     } while (defined $clause);
#   }
#   my @neworder;
#   foreach my $i3 (0.. $#all) {
#     push @neworder, $all[$reorder->{$i3}];
#   }
#   return {
# 	  Success => 1,
# 	  Interlingua => \@neworder,
# 	 };
# }

sub ConvertPrologToInterLingua {
  my ($self,%args) = @_;
  my $order = {};
  my $iorder = {};
  my $reorder = {};

  my $prolog1 = $args{Prolog};
  my $i1 = 0;
  my @statements1;
  my @tmp1 = split /\)\.\n/, $prolog1;
  $tmp1[-1] =~ s/\)\.$//;
  my @swipli;
  print Dumper({Tmp1 => \@tmp1}) if $self->Debug;
  foreach my $statement (@tmp1) {
    $statement =~ s/^\s*//sg;
    my @res;
    try {
      @res = swi_parse($statement);;
    }
      catch {
	$statement .= ".";
	try {
	  @res = swi_parse($statement);;
	}
	  catch {
	    $statement =~ s/.$//;
	    $statement .= ").";
	    try {
	      @res = swi_parse($statement);;
	    } catch {
	      # FIXME: throw error
	    }
	  };
      };
    print Dumper({Res => \@res}) if $self->Debug;

    print Dumper(\@res) if $UNIVERSAL::debug;
    push @swipli, $res[0];
  }
  my @interlingua;
  foreach my $assertion (@swipli) {
    my $res = $self->ParentSelf->Types->{SWIPL}->ConvertSWIPLToInterlingua
      (
       SWIPL => [$assertion],
      );
    if ($res->{Success}) {
      push @interlingua, $res->{Interlingua}->[0];
    }
  }
  return {
	  Success => 1,
	  Interlingua => \@interlingua,
	 };
}

sub ConvertInterlinguaToProlog {
  my ($self,%args) = @_;
  my @res;
  exists $args{Depth} or $args{Depth} = 0;
  my $interlingua = $args{Interlingua};
  my $type = ref $interlingua;
  if ($type eq "ARRAY") {
    if ($args{Depth} > 0) {
      my $predicate = shift @$interlingua;
      my $type2 = ref($predicate);
      if ($type2 eq "ARRAY") {
	unshift @$interlingua, $predicate;
	$predicate = "sarray";
      }
      if ($args{Depth} == 1 and defined $predicate and $predicate eq 'implies' and scalar @$interlingua == 2) {
	my @inner1;
	my $subdomain1 = $interlingua->[1];
	my $res1 = $self->ConvertInterlinguaToProlog
	  (
	   Parens => 1,
	   Interlingua => $subdomain1,
	   Depth => $args{Depth} + 1,
	  );
	if ($res1->{Success}) {
	  if (ref($res1->{Prolog}) eq 'ARRAY') {
	    push @inner1, join("",@{$res1->{Prolog}});
	  } else {
	    push @inner1, $res1->{Prolog};
	  }
	} else {
	  return $res1;
	}

	my @inner0;
	my $subdomain0 = $interlingua->[0];
	my $res0 = $self->ConvertInterlinguaToProlog
	  (
	   Parens => 1,
	   Interlingua => $subdomain0,
	   Depth => $args{Depth} + 1,
	   Clause => $args{Clause},
	  );
	if ($res0->{Success}) {
	  if (ref($res0->{Prolog}) eq 'ARRAY') {
	    push @inner0, join("",@{$res0->{Prolog}});
	  } else {
	    push @inner0, $res0->{Prolog};
	  }
	} else {
	  return $res0;
	}
	if ($inner0[0] =~ /^and\((.+)\)$/s) {
	  $inner0[0] = $1;
	}
	push @res, \@inner1, " :-\n\t", \@inner0;
      } else {
	my $tmp = $self->ConvertInterlinguaToSingleQuotedTerm
	  (
	   Interlingua => $predicate,
	   Depth => 0,
	  );
	if ($tmp->{Success}) {
	  push @res, $tmp->{Prolog};
	} else {
	  # FIXME: what to do here
	}
	if (scalar @$interlingua) {
	  push @res, '(';
	  my @inner;
	  foreach my $subdomain (@$interlingua) {
	    my $res = $self->ConvertInterlinguaToProlog
	      (
	       Parens => 1,
	       Interlingua => $subdomain,
	       Depth => $args{Depth} + 1,
	      );
	    if ($res->{Success}) {
	      if (ref($res->{Prolog}) eq 'ARRAY') {
		push @inner, join("",@{$res->{Prolog}});
	      } else {
		push @inner, $res->{Prolog};
	      }
	    } else {
	      return $res;
	    }
	  }
	  push @res, \@inner;
	  push @res, ")";
	}
      }
    } else {
      foreach my $subdomain (@$interlingua) {
	my $res = $self->ConvertInterlinguaToProlog
	  (
	   Interlingua => $subdomain,
	   Depth => $args{Depth} + 1,
	  );
	if ($res->{Success}) {
	  if (ref($res->{Prolog}) eq 'ARRAY') {
	    push @res, join("",@{$res->{Prolog}});
	  } else {
	    push @res, $res->{Prolog};
	  }
	}
      }
    }
  } elsif ($type eq "GLOB") {
    my $tmp = TermIsVariable($interlingua);
    $tmp =~ s/^\?//;
    # check that the variable meets the syntax
    return {
	    Success => 1,
	    Prolog => uc($tmp),
	   };
  } else {
    # this is a string
    return $self->ConvertInterlinguaToSingleQuotedTerm
      (
       Interlingua => $interlingua,
       Depth => 0,
      );
  }
  my $retval;
  my @final;
  foreach my $item (@res) {
    if (ref($item) eq 'ARRAY') {
      push @final, join(',',@$item);
    } else {
      push @final, $item;
    }
  }
  if ($args{Depth} == 1) {
    push @final, ".\n";
  }
  $retval = join("",@final);
  if ($args{Depth} == 0 and $retval eq '0') {
    $retval = "\n";
  }
  return {
	  Success => 1,
	  Prolog => $retval,
	 };
}

sub ConvertInterlinguaToSingleQuotedTerm {
  my ($self,%args) = @_;
  my $interlingua = $args{Interlingua};
  my $ref = ref($interlingua);
  if ($ref eq 'ARRAY') {
    my $res = $self->ConvertInterlinguaToProlog
      (
       Parens => 1,
       Interlingua => $interlingua,
       Depth => 1,
      );
    if ($res->{Success}) {
      $res->{Prolog} =~ s/\.$//;
      return {
	      Success => 1,
	      Prolog => 'array('.$res->{Prolog}.')',
	     };
    } else {
      return {};
    }
  } else {
    if ($interlingua =~ /[^a-zA-Z0-9_]/ or $interlingua =~ /^[A-Z0-9]/ or $interlingua eq '') {
      $interlingua =~ s/\'/_SINGLEQUOTE_/sg;
      if ($interlingua =~ /^[a-z][a-zA-Z0-9_]+$/) {
	return {
		Success => 1,
		Prolog => $interlingua,
	       };
      } elsif ($interlingua =~ /^[A-Z][A-Z0-9-_]+$/) {
	return {
		Success => 1,
		Prolog => "'".$interlingua."'",
	       };
      } else {
	return {
		Success => 1,
		Prolog => "'".$interlingua."'",
	       };
      }
    } else {
      # FIXME: this is a place holder
      # print STDERR "Warning: Incorrect prolog, FIXME.\n";
      return {
	      Success => 1,
	      Prolog => $interlingua,
	     };
    }
  }
}

sub ConvertItemToKBS {
  my ($self,%args) = @_;
  my @res;
  my $item = $args{Item};
  my $ref = ref $item;
  if ($ref eq "AI::Prolog::Term") {
    if (defined $item->{functor} and ! scalar @{$item->{args}}) {
      return $item->{functor};
    } elsif (defined $item->{functor} and scalar @{$item->{args}}) {
      push @res, $item->{functor};
      # now get out the args
      foreach my $arg (@{$item->{args}}) {
	push @res, $self->ConvertItemToKBS
	  (
	   Item => $arg,
	  );
      }
      return \@res;
    } elsif (defined $item->{varname}) {
      my $varname = $item->{varname};
      return \*{"::?$varname"}
    }
  } elsif ($ref eq "AI::Prolog::Term::Number") {
    return $item->{functor};
  }
  return $item;
}

1;
