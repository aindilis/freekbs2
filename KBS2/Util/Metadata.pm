package KBS2::Util::Metadata;

use KBS2::Client;
use KBS2::Util;
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Context MyClient Metadata MultivaluedPredicates /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Context($args{Context});
  $self->MyClient
    (KBS2::Client->new
     (
      Context => $self->Context,
      Debug => $args{Debug},
     ));
  $self->Metadata({});
}

sub LoadMetadata {
  my ($self,%args) = @_;
  $self->MultivaluedPredicates({});
  my $assertions = [];
  if ($args{Assertions}) {
    $assertions = $args{Assertions};
  } else {
    my $message = $self->MyClient->Send
      (
       QueryAgent => 1,
       Command => "all-asserted-knowledge",
       Context => $self->Context,
      );
    if (defined $message) {
      $assertions = $message->{Data}->{Result};
    }
  }
  if (scalar @$assertions) {
    $self->ProcessAssertions(Assertions => $assertions);
  }
}

sub ProcessAssertions {
  my ($self,%args) = @_;
  my $assertions = $args{Assertions};
  foreach my $assertion (@$assertions) {
    my $pred = $assertion->[0];
    if ($pred eq "multivalued-predicate") {
      $self->MultivaluedPredicates->{$assertion->[1]} = 1;
    }
  }
  foreach my $assertion (@$assertions) {
    my $pred = $assertion->[0];
    my $arity = scalar @$assertion - 1;
    if ($arity == 1) {
      # if (exists $self->MultivaluedPredicates->{$pred}) {
	$self->Metadata->{$pred}->{DumperQuote2($assertion->[1])} = 1;
      # } else {
      # $self->Metadata->{$pred} = $assertion->[1];
      # }
    } elsif ($arity == 2) {
      if (exists $self->MultivaluedPredicates->{$pred}) {
	$self->Metadata->{$pred}->{DumperQuote2($assertion->[1])}->{$assertion->[2]} = 1;
      } else {
	$self->Metadata->{$pred}->{DumperQuote2($assertion->[1])} = $assertion->[2];
      }
    }
  }
}

sub ProcessUnassertions {
  my ($self,%args) = @_;
  my $unassertions = $args{Unassertions};
  #   foreach my $unassertion (@$unassertions) {
  #     my $pred = $unassertion->[0];
  #     if ($pred eq "multivalued-predicate") {
  #       $self->MultivaluedPredicates->{$unassertion->[1]} = 1;
  #     }
  #  }
  foreach my $unassertion (@$unassertions) {
    my $pred = $unassertion->[0];
    my $arity = scalar @$unassertion - 1;
    if ($arity == 1) {
      if (exists $self->MultivaluedPredicates->{$pred}) {
	delete $self->Metadata->{$pred}->{$unassertion->[1]};
	if (! scalar keys %{$self->Metadata->{$pred}}) {
	  delete $self->Metadata->{$pred};
	}
      } else {
	delete $self->Metadata->{$pred};
      }
    } elsif ($arity == 2) {
      if (exists $self->MultivaluedPredicates->{$pred}) {
	delete $self->Metadata->{$pred}->{DumperQuote2($unassertion->[1])}->{$unassertion->[2]};
	if (! scalar keys %{$self->Metadata->{$pred}->{DumperQuote2($unassertion->[1])}}) {
	  delete $self->Metadata->{$pred}->{DumperQuote2($unassertion->[1])};
	}
	if (! scalar keys %{$self->Metadata->{$pred}}) {
	  delete $self->Metadata->{$pred};
	}
      } else {
	delete $self->Metadata->{$pred}->{DumperQuote2($unassertion->[1])};
	if (! scalar keys %{$self->Metadata->{$pred}}) {
	  delete $self->Metadata->{$pred};
	}
      }
    }
  }
}

sub DeleteMetadata {
  my ($self,%args) = @_;
  my $item = DumperQuote2($args{Item});
  my @unassertions;
  my @predicates;
  if ($args{Predicates}) {
    @predicates = @{$args{Predicates}};
  } else {
    @predicates = keys %{$self->Metadata};
  }
  foreach my $predicate (@predicates) {
    if (exists $self->Metadata->{$predicate}->{$item}) {
      push @unassertions, [$predicate,$args{Item},$self->Metadata->{$predicate}->{$item}];
      delete $self->Metadata->{$predicate}->{$item};
    }
  }

  # first unassert the old value
  my %sendargs =
    (
     Unassert => \@unassertions,
     Context => $self->Context,
     QueryAgent => 1,
     InputType => "Interlingua",
     Flags => {
	       AssertWithoutCheckingConsistency => 1,
	      },
    );
  print Dumper(\%sendargs);
  my $res = $self->MyClient->Send(%sendargs);
  print Dumper({DeleteResult => $res});
}

sub GetMetadata {
  my ($self,%args) = @_;
  if ($args{Item}) {
    my $item = DumperQuote2($args{Item});
    if (exists $self->Metadata->{$args{Predicate}}->{$item}) {
      return {
	      Success => 1,
	      Result => $self->Metadata->{$args{Predicate}}->{$item},
	     };
    }
    return {
	    Success => 0,
	   };
  } else {
    if (exists $self->Metadata->{$args{Predicate}}) {
      my @res;
      foreach my $key (keys %{$self->Metadata->{$args{Predicate}}}) {
	push @res, DeDumperQuote2($key);
      }
      return {
	      Success => 1,
	      Result => \@res,
	     };
#       return {
# 	      Success => 1,
# 	      Result => $self->Metadata->{$args{Predicate}},
# 	     };
    }
    return {
	    Success => 0,
	   };
  }
}

sub SetMetadata {
  my ($self,%args) = @_;
  if ($args{Item}) {
    my $item = DumperQuote2($args{Item});
    my $assert = 0;
    if (exists $self->Metadata->{$args{Predicate}}->{$item} and ! $args{Multivalued}) {
      if (DumperQuote2($args{Value}) ne DumperQuote2($self->Metadata->{$args{Predicate}}->{$item})) {
	# update the value in the KB and the array

	# first unassert the old value
	my %sendargs =
	  (
	   Unassert => [[$args{Predicate},$args{Item},$self->Metadata->{$args{Predicate}}->{$item}]],
	   Context => $self->Context,
	   QueryAgent => 1,
	   InputType => "Interlingua",
	   Flags => {
		     AssertWithoutCheckingConsistency => 1,
		    },

	  );
	print Dumper(\%sendargs);
	my $res = $self->MyClient->Send(%sendargs);
	print Dumper({UnassertResult => $res});

	# make sure that succeeded
	$assert = 1;
      } else {
	# it's fine, leave it alone
      }
    } else {
      # assert the value into the KB
      $assert = 1;
    }
    if ($assert) {
      # send the new value
      %sendargs =
	(
	 Assert => [[$args{Predicate},$args{Item},$args{Value}]],
	 Context => $self->Context,
	 QueryAgent => 1,
	 InputType => "Interlingua",
	 Flags => {
		   AssertWithoutCheckingConsistency => 1,
		  },
	);
      print Dumper(\%sendargs);
      my $res = $self->MyClient->Send(%sendargs);
      print Dumper({AssertResult => $res});

      if ($args{Multivalued}) {
	$self->Metadata->{$args{Predicate}}->{$item}->{$args{Value}} = 1;
      } else {
	$self->Metadata->{$args{Predicate}}->{$item} = $args{Value};
      }
    }
  } else {

  }
}

sub RemoveMetadata {
  my ($self,%args) = @_;
  my $item = DumperQuote2($args{Item});
  if (exists $self->Metadata->{$args{Predicate}}->{$item} and
      exists $self->Metadata->{$args{Predicate}}->{$item}->{$args{Value}}) {
    # first unassert the old value
    my %sendargs =
      (
       Unassert => [[$args{Predicate},$args{Item},$args{Value}]],
       Context => $self->Context,
       QueryAgent => 1,
       InputType => "Interlingua",
       Flags => {
		 AssertWithoutCheckingConsistency => 1,
		},
      );
    print Dumper(\%sendargs);
    my $res = $self->MyClient->Send(%sendargs);
    print Dumper({RemoveResult => $res});
    delete $self->Metadata->{$args{Predicate}}->{$item}->{$args{Value}};
  } else {
    # it's fine, leave it alone
  }
}

sub SetMultivalued {
  my ($self,%args) = @_;
  # check if there
  my $assert = {};
  my $unassert = {};
  my $dontassert = {};

  my $res = $self->GetMetadata
    (
     Item => $args{Item},
     Predicate => $args{Predicate},
    );

  return {
	  Success => 0,
	 } unless $res->{Success};
  my $values = $res->{Result};
  # get the values here
  foreach my $value (keys %$values) {
    if (! exists $args{Values}->{$value}) {
      $unassert->{$value} = 1;
    } else {
      $dontassert->{$value} = 1;
    }
  }
  foreach my $value (keys %{$args{Values}}) {
    if (! exists $dontassert->{$value}) {
      $assert->{$value} = 1;
    }
  }

  # now perform all the movements and redraw affected windows
  my $changes = {};
  foreach my $value (keys %$unassert) {
    $changes->{$value} = 1;
    my $res = $self->RemoveMetadata
      (
       Item => $args{Item},
       Predicate => $args{Predicate},
       Value => $value,
      );
  }
  foreach my $value (keys %$assert) {
    $changes->{$value} = 1;
    my $res = $self->SetMetadata
      (
       Item => $args{Item},
       Predicate => $args{Predicate},
       Value => $value,
       Multivalued => 1,
      );
  }
  return {
	  Success => 1,
	  Changes => $changes,
	 };
}

sub SetUnaryPredicate {
  my ($self,%args) = @_;
  if ($args{Item}) {
    my $item = DumperQuote2($args{Item});
    my $assert = 0;
    print Dumper({
		  Metadata => $self->Metadata,
		  Pred => $self->Metadata->{$args{Predicate}},
		 });
    if (exists $self->Metadata->{$args{Predicate}} and exists $self->Metadata->{$args{Predicate}}->{$item}) {
      # do nothing it is already set
    } else {
      # set it
      %sendargs =
	(
	 Assert => [[$args{Predicate},$args{Item}]],
	 Context => $self->Context,
	 QueryAgent => 1,
	 InputType => "Interlingua",
	 Flags => {
		   AssertWithoutCheckingConsistency => 1,
		  },
	);
      print Dumper(\%sendargs);
      my $res = $self->MyClient->Send(%sendargs);
      print Dumper({AssertResult => $res});
      $self->Metadata->{$args{Predicate}}->{$item} = 1;
    }
  }
}

sub UnsetUnaryPredicate {
  my ($self,%args) = @_;
  if ($args{Item}) {
    my $item = DumperQuote2($args{Item});
    my $assert = 0;
    if (exists $self->Metadata->{$args{Predicate}} and exists $self->Metadata->{$args{Predicate}}->{$item}) {
      # print Dumper({Args => \%args});
      # unassert it
      my %sendargs =
	(
	 Unassert => [[$args{Predicate},$args{Item}]],
	 Context => $self->Context,
	 QueryAgent => 1,
	 InputType => "Interlingua",
	 Flags => {
		   AssertWithoutCheckingConsistency => 1,
		  },
	);
      print Dumper(\%sendargs);
      my $res = $self->MyClient->Send(%sendargs);
      print Dumper({RemoveResult => $res});
      delete $self->Metadata->{$args{Predicate}}->{$item};
    } else {
      # do nothing it isn't set
    }
  }
}

sub GetAllAssertions {
  my ($self,%args) = @_;
  # for now use this
  my $assertions = [];
  my $message = $self->MyClient->Send
    (
     QueryAgent => 1,
     Command => "all-asserted-knowledge",
     Context => $self->Context,
    );
  if (defined $message) {
    $assertions = $message->{Data}->{Result};
  }
  return $assertions;

  # in the future reconstruct from the data for efficient querying

}

1;
