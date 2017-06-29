package KBS2::ImportExport::Mod::SWIPL;

use KBS2::Util;
use Language::Prolog::Types qw(:util :ctors);
use PerlLib::SwissArmyKnife;

print STDERR "warning: SWIPL import export not fully functional\n";

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Types Debug /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug} || $UNIVERSAL::debug);
  $self->Types
    ({
      "Interlingua" => 1,
      "SWIPL" => 1,
      "SWIPLI" => 1,
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
  } elsif ($args{InputType} eq "SWIPL") {
    my $res = $self->ConvertSWIPLToInterlingua
      (
       SWIPL => $args{Input},
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Interlingua => $res->{Interlingua},
	     };
    } else {
      return $res;
    }
  } elsif ($args{InputType} eq "SWIPLI") {
    my $res = $self->ConvertSWIPLIToInterlingua
      (
       SWIPLI => $args{Input},
      );
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
  } elsif ($args{OutputType} eq "SWIPL") {
    my $res = $self->ConvertInterlinguaToSWIPL
      (
       Interlingua => $args{Interlingua},
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Output => $res->{SWIPL},
	     };
    } else {
      return $res;
    }
  } elsif ($args{OutputType} eq "SWIPLI") {
    my $res = $self->ConvertInterlinguaToSWIPLI
      (
       Interlingua => $args{Interlingua},
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Output => $res->{SWIPLI},
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

sub ConvertSWIPLToInterlingua {
  my ($self,%args) = @_;
  my $item = $args{SWIPL}[0];
  my $ref = ref($item);
  print ClearDumper
    ({
      Ref => $ref,
      ArgsConversion => \%args,
     }) if $UNIVERSAL::debug;
  if ($ref eq '') {
    return {
	    Success => 1,
	    Interlingua => [$item],
	   };
  } elsif ($ref eq 'Language::Prolog::Types::Internal::nil') {
    return {
	    Success => 1,
	    Interlingua => [undef],
	   };
  } elsif ($ref eq 'Language::Prolog::Types::Internal::list') {
    my @list = prolog_list2perl_list($item);
    print ClearDumper({List2 => \@list}) if $UNIVERSAL::debug;
    my @res;
    foreach my $entry (@list) {
      my $res = $self->ConvertSWIPLToInterlingua(SWIPL => [$entry]);
      if ($res->{Success}) {
	push @res, $res->{Interlingua}[0];
      } else {
	# FIXME: throw
      }
    }
    unshift @res, '_prolog_list';
    return {
	    Success => 1,
	    Interlingua => [\@res],
	   };
  } elsif ($ref eq 'Language::Prolog::Types::Internal::ulist') {
    my @list;
    my $lastitem = pop @$item;
    foreach my $subitem (@$item) {
      push @list, $self->ConvertSWIPLToInterlingua(SWIPL => [$subitem])
    }
    push @list, $self->ConvertSWIPLToInterlingua(SWIPL => [$lastitem]);
    my @res;
    foreach my $entry (@list) {
      if ($entry->{Success}) {
	push @res, $entry->{Interlingua}[0];
      } else {
	# FIXME: throw
      }
    }
    unshift @res, '_prolog_list';
    return {
	    Success => 1,
	    Interlingua => [\@res],
	   };
  } elsif ($ref eq 'Language::Prolog::Types::Internal::functor') {
    my @list;
    my $functor = shift @$item;
    push @list, $functor;
    foreach my $entry (@$item) {
      my $res = $self->ConvertSWIPLToInterlingua(SWIPL => [$entry]);
      if ($res->{Success}) {
	push @list, $res->{Interlingua}[0];
      } else {
	# FIXME: throw
      }
    }
    return {
	    Success => 1,
	    Interlingua => [\@list],
	   };
  } elsif ($ref eq 'Language::Prolog::Types::Internal::variable') {
    print ClearDumper({SWIVar => swi_var($item)}) if $UNIVERSAL::debug;
    return {
	    Success => 1,
	    Interlingua => [Var('?'.Language::Prolog::Types::Internal::variable::name($item))],
	   };
  } elsif ($ref eq 'Language::Prolog::Types::Internal::opaque') {
  } elsif ($ref eq 'ARRAYREF') {
    die "Oops fudge\n";
    # FIX Interlinuga => @$item below
    # return {
    # 	    Success => 1,
    # 	    Interlingua => @$item,
    # 	   };
  }
}

sub ConvertInterlinguaToSWIPL {
  my ($self,%args) = @_;
  print Dumper({Interlingua => $args{Interlingua}}) if $UNIVERSAL::debug;
  my $item = $args{Interlingua}[0];
  my $ref = ref($item);
  # $UNIVERSAL::debug = 1;
  print ClearDumper
    ({
      Ref => $ref,
      ArgsConversion => \%args,
     }) if $UNIVERSAL::debug;
  if (! defined $ref) {
    return {
	    Success => 1,
	    SWIPL => [prolog_nil],
	   };
  } elsif ($ref eq '') {
    if (defined $item) {
      if ($item =~ /^[0-9]+$/) {
	return {
		Success => 1,
		SWIPL => [$item],
	       };
      } else {
	return {
		Success => 1,
		SWIPL => [prolog_atom($item)],
	       };
      }
    } else {
	return {
		Success => 1,
		SWIPL => [prolog_nil],
	       };
    }
  } elsif ($ref eq 'ARRAY') {
    if (scalar @$item) {
      if ($item->[0] eq '_prolog_list') {
	shift @$item;
	my @newlist;
	foreach my $subitem (@$item) {
	  my $res = $self->ConvertInterlinguaToSWIPL(Interlingua => [$subitem]);
	  if ($res->{Success}) {
	    push @newlist, $res->{SWIPL}[0];
	  } else {
	    # FIXME: throw
	  }
	}
	return {
		Success => 1,
		SWIPL => [prolog_list(@newlist)],
	       };
      } else {
	my $name = shift @$item;
	my @newlist;
	foreach my $subitem (@$item) {
	  my $res = $self->ConvertInterlinguaToSWIPL(Interlingua => [$subitem]);
	  if ($res->{Success}) {
	    push @newlist, $res->{SWIPL}[0];
	  } else {
	    # FIXME: throw
	  }
	}
	return {
		Success => 1,
		SWIPL => [prolog_functor($name,@newlist)],
	       };

      }
    } else {
      my @emptylist;
      return {
	      Success => 1,
	      SWIPL => [prolog_list(@emptylist)],
	     };
    }
  } elsif ($ref eq 'HASH') {
    my @newlist;
    foreach my $key (sort keys %$item) {
      my $value = $item->{$key};
      my $res1 = $self->InterlinguaToSWIPL(Interlingua => $key);
      if ($res1->{Success}) {
	push  @newlist, $res1->{SWIPL};
      } else {
	# FIXME: throw
      }
      my $res2 = $self->InterlinguaToSWIPL(Interlingua => $value);
      if ($res2->{Success}) {
	push  @newlist, $res2->{SWIPL};
      } else {
	# FIXME: throw
      }

    }
    return {
	    Success => 1,
	    SWIPL => [prolog_list(@newlist)],
	   };
  } elsif ($ref eq 'Language::Prolog::Types::Internal::ulist') {
    # FIXME: throw error "";
  } elsif ($ref eq 'Language::Prolog::Types::Internal::functor') {
    # FIXME: throw error "";
  } elsif ($ref eq 'GLOB' and defined TermIsVariable($item)) {
    my $var = TermIsVariable($item);
    $var =~ s/^\?//sg;
    my $prologvar = prolog_var($var);
    return {
	    Success => 1,
	    SWIPL => [$prologvar],
	   };
  } elsif ($ref eq 'Language::Prolog::Types::Internal::opaque') {
    # FIXME: throw error "";
  }
}

1;
