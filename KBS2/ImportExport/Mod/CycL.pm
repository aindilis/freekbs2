package KBS2::ImportExport::Mod::CycL;

use KBS2::Util;
use Manager::Misc::Light2;
use PerlLib::SwissArmyKnife;
# use System::Cyc::OpenCyc::Java::CycAccess;
use System::Cyc::ResearchCyc::Java::CycAccess;
# use System::Cyc::ResearchCyc1_0::Java::CycAccess;
# use System::Cyc::EnterpriseCyc::Java::CycAccess;

use Data::Dumper;
use File::Slurp;
use Inline::Java qw(caught);
use MIME::Base64 qw(encode_base64);
use Moose;
use Try::Tiny;

# use System::Cyc::OpenCyc::Java::CycLParserUtil;
use System::Cyc::ResearchCyc::Java::CycLParserUtil;
# use System::Cyc::ResearchCyc1_0::Java::CycLParserUtil;
# use System::Cyc::EnterpriseCyc::Java::CycLParserUtil;

has 'Debug' =>
  (
   is      => 'rw',
   isa     => 'Int',
   default => sub {
     return 0;
   },
  );

has 'OpenCycLParserUtil' =>
  (
   is      => 'rw',
   lazy    => 1,
   default => sub {
     my $cyclparserutil;
     try {
       # $cyclparserutil = System::Cyc::OpenCyc::Java::CycLParserUtil->new();
     } catch {
       my $exception = $_;
       if ($exception->can('toString')) {
	 warn $exception->toString;
       } elsif ($exception->can('msg')) {
	 warn $exception->msg;
       } else {
	 warn Dumper($exception);
       }
     };
     return $cyclparserutil;
   },
  );

has 'ResearchCycLParserUtil' =>
  (
   is      => 'rw',
   lazy    => 1,
   default => sub {
     my $cyclparserutil;
     try {
       $cyclparserutil = System::Cyc::ResearchCyc::Java::CycLParserUtil->new();
     } catch {
       my $exception = $_;
       if ($exception->can('toString')) {
	 warn $exception->toString;
       } elsif ($exception->can('msg')) {
	 warn $exception->msg;
       } else {
	 warn Dumper($exception);
       }
     };
     return $cyclparserutil;
   },
  );

has 'ResearchCyc1_0LParserUtil' =>
  (
   is      => 'rw',
   lazy    => 1,
   default => sub {
     my $cyclparserutil;
     try {
       $cyclparserutil = System::Cyc::ResearchCyc1_0::Java::CycLParserUtil->new();
     } catch {
       my $exception = $_;
       if ($exception->can('toString')) {
	 warn $exception->toString;
       } elsif ($exception->can('msg')) {
	 warn $exception->msg;
       } else {
	 warn Dumper($exception);
       }
     };
     return $cyclparserutil;
   },
  );

has 'CycLParserUtil' =>
  (
   is      => 'rw',
   lazy    => 1,
   default => undef,
  );

has 'Light' =>
  (
   is      => 'ro',
   lazy    => 1,
   default => sub { Manager::Misc::Light2->new },
  );

has 'Types' =>
  (
   is      => 'ro',
   lazy    => 1,
   default => sub { return {
			    "Interlingua" => 1,
			    "CycL Light Domain" => 1,
			    "CycL String" => 1,
			    "Cyclified String" => 1,
			    "OpenCycAPI" => 1,
			    "OpenCycLString" => 1,
			    "ResearchCycAPI" => 1,
			    "ResearchCycLString" => 1,
			    "ResearchCyc1_0API" => 1,
			    "ResearchCyc1_0LString" => 1,
			   } },
  );

has 'ConstantLookup' => ( is => 'rw', isa => 'HashRef' );

sub BUILD {
  my ($self,%args) = (shift, %{$_[0]});

  # in the future, make sure to startup Cyc here

  # a lookup table for defined CycL constants, for use in translating
  # from the Interlingua to CycL
  $self->ConstantLookup({});
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
  # convert to a perl formula
  if ($args{InputType} eq "Interlingua") {
    return {
	    Success => 1,
	    Interlingua => $args{Input},
	   };
  } elsif ($args{InputType} eq "CycL String" or
	   $args{InputType} eq 'Cyclified String') {
    # now we have to convert this
    my $res = $self->ConvertCycLStringToInterlingua
      (
       CycLString => $args{Input},
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Interlingua => $res->{Interlingua},
	     };
    } else {
      return $res;
    }
  } elsif ($args{InputType} eq "CycL Light Domain") {
    print Dumper({ConvertToInterlinguaArgs => \%args}) if $self->Debug;
    NotYetImplemented();
  } elsif ($args{InputType} eq "OpenCycAPI") {
    # now we have to convert this
    my $res = $self->ConvertCycAPIToInterlingua
      (
       OpenCycAPI => $args{Input},
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Interlingua => $res->{Interlingua},
	     };
    } else {
      return $res;
    }
  } elsif ($args{InputType} eq "ResearchCycAPI") {
    # now we have to convert this
    my $res = $self->ConvertCycAPIToInterlingua
      (
       ResearchCycAPI => $args{Input},
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Interlingua => [$res->{Interlingua}],
	     };
    } else {
      return $res;
    }
  } elsif ($args{InputType} eq "ResearchCyc1_0API") {
    # now we have to convert this
    my $res = $self->ConvertCycAPIToInterlingua
      (
       ResearchCyc1_0API => $args{Input},
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Interlingua => [$res->{Interlingua}],
	     };
    } else {
      return $res;
    }
  } elsif ($args{InputType} eq "EnterpriseCycAPI") {
    NotYetImplemented();
  } else {
    return {
	    Success => 0,
	    Reasons => {
			"Unknown InputType" => $args{InputType},
		       }
	   };
  }
}

sub ConvertToOutputType {
  my ($self,%args) = @_;
  if ($args{OutputType} eq "Interlingua") {
    return {
	    Success => 1,
	    Output => $args{Interlingua},
	   };
  } elsif ($args{OutputType} eq "CycL String") {
    my $res = $self->ConvertInterlinguaToCycLString
      (Interlingua => $args{Interlingua});
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Output => $res->{"CycLString"},
	     };
    } else {
      return $res;
    }
  } elsif ($args{OutputType} eq "Cyclified String") {
    my $res = $self->ConvertInterlinguaToCyclifiedString
      (Interlingua => $args{Interlingua});
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Output => $res->{Output},
	     };
    } else {
      return $res;
    }
  } elsif ($args{OutputType} eq "ResearchCycAPI") {
    my $res = $self->ConvertInterlinguaToCycLString
      (Interlingua => $args{Interlingua});
    if ($res->{Success}) {
      my $res2 = $self->ConvertCycLStringToCycAPI
	(
	 ResearchCycLString => $res->{'CycLString'},
	);
      if ($res2->{Success}) {
	return {
		Success => 1,
		Output => $res2->{'CycAPI'},
	       };
      } else {
	return $res2;
      }
    } else {
      return $res;
    }
  } elsif ($args{OutputType} eq "ResearchCyc1_0API") {
    my $res = $self->ConvertInterlinguaToCycLString
      (Interlingua => $args{Interlingua});
    if ($res->{Success}) {
      my $res2 = $self->ConvertCycLStringToCycAPI
	(
	 ResearchCyc1_0LString => $res->{'CycLString'},
	);
      if ($res2->{Success}) {
	return {
		Success => 1,
		Output => $res2->{'CycAPI'},
	       };
      } else {
	return $res2;
      }
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

# sub CycLDequote {
#   my ($self,%args) = @_;
#   my $iterator = $args{CycList}->cycListApiValue->iterator;
#   $iterator->next->toString;
#   my $next = $iterator->next;
#   print $next->toString."\n";
#   print ref($next)."\n";
#   return $next;
# }

sub ConvertCycAPIToInterlingua {
  my ($self,%args) = @_;
  my $cyclstring;
  if ($args{OpenCycAPI}) {
    return $self->ConvertCycAPIToInterlinguaHelper
      (
       CycAPI => $args{OpenCycAPI},
      );
  } elsif ($args{ResearchCycAPI}) {
    return $self->ConvertCycAPIToInterlinguaHelper
      (
       CycAPI => $args{ResearchCycAPI},
      );
  } elsif ($args{ResearchCyc1_0API}) {
    return $self->ConvertCycAPIToInterlinguaHelper
      (
       CycAPI => $args{ResearchCyc1_0API},
      );
  } elsif ($args{EnterpriseCycAPI}) {
    return $self->ConvertCycAPIToInterlinguaHelper
      (
       CycAPI => $args{EnterpriseCycAPI},
      );
  }
}

sub getCycLParserUtil {
  my ($self,%args) = @_;
  print "1\n";
  if (defined $self->OpenCycLParserUtil) {
    print "a\n";
    $self->CycLParserUtil($self->OpenCycLParserUtil);
  } elsif (defined $self->ResearchCycLParserUtil) {
    print "b\n";
    $self->CycLParserUtil($self->ResearchCycLParserUtil);
  } elsif (defined $self->ResearchCyc1_0LParserUtil) {
    print "c\n";
    $self->CycLParserUtil($self->ResearchCyc1_0LParserUtil);
  } else {
    # FIXME: throw error
    print "Wth!\n";
  }
  return $self->CycLParserUtil;
}

sub ConvertCycLStringToCycAPI {
  my ($self,%args) = @_;
  my $parse;
  my $result;
  print Dumper({ConvertCycLStringToCycAPI => \%args}) if $self->Debug;
  if (defined $args{OpenCycLString}) {
    try {
      $parse = $self->OpenCycLParserUtil->parseCycLSentence('(#$and '.$args{OpenCycLString}.')');
    } catch {
      my $exception = $_;
      if ($exception->can('toString')) {
	warn $exception->toString;
      } elsif ($exception->can('msg')) {
	warn $exception->msg;
      } else {
	warn Dumper($exception);
      }
    };
  } elsif (defined $args{CycLString} or defined $args{ResearchCycLString} or defined $args{ResearchCyc1_0LString}) {
    try {
      my $tmp = $args{ResearchCycLString} || $args{ResearchCyc1_0LString} || $args{CycLString};
      print "ToParse: $tmp\n" if $self->Debug;
      my $string;
      if ($tmp =~ /\(/) {
	$string = $tmp;
	$parse = $self->getCycLParserUtil->parseCycLSentence
	  ($string);
      } elsif ($tmp !~ /\s/) {
       	$string = '(#$isa '.$tmp.' ?X)';
       	$result = $self->getCycLParserUtil->parseCycLSentence
       	  ($string);
	$parse = $result;
	my $iterator0 = $parse->cycListApiValue->listIterator();
	if ($iterator0->hasNext) {
	  $iterator0->next;
	  if ($iterator0->hasNext) {
	    my $iterator1 = $iterator0->next->cycListApiValue->listIterator();
	    if ($iterator1->hasNext) {
	      $iterator1->next;
	      if ($iterator1->hasNext) {
		$parse = $iterator1->next;
	      }
	    }
	  }
	}
      } else {
	NotYetImplemented();
      }
      print Dumper({Parse => $parse}) if $self->Debug; # if $self->Debug;

    } catch {
      my $exception = $_;
      if ($exception->can('toString')) {
	warn $exception->toString;
      } elsif ($exception->can('msg')) {
	warn $exception->msg;
      } else {
	warn Dumper($exception);
      }
    };
  } elsif (defined $args{EnterpriseCycLString}) {
    NotYetImplemented();
  }
  print "Parse: ".$parse->toString."\n" if $self->Debug;
  return {
	  Success => 1,
	  CycAPI => $parse,
	 };
}

sub ConvertCycLStringToInterlingua {
  my ($self,%args) = @_;
  my $res = $self->ConvertCycLStringToCycAPI
    (
     CycLString => $args{CycLString},
     ResearchCycLString => $args{ResearchCycLString},
     ResearchCyc1_0LString => $args{ResearchCyc1_0LString},
     OpenCycLString => $args{OpenCycLString},
    );
  if (! $res->{Success}) {
    return $res;
  }

  my $res2 = $self->ConvertCycAPIToInterlinguaHelper(CycAPI => $res->{CycAPI});
  print Dumper($res2) if $self->Debug;
  my @res;

  if (ref($res2->{Interlingua}) eq 'ARRAY' and $res2->{Interlingua}->[0] eq 'QUOTE' and scalar @{$res2->{Interlingua}} == 2) {
    @res = @{$res2->{Interlingua}->[1]};
  } else {
    @res = @{$res2->{Interlingua}};
  }
  print Dumper({ResRes => \@res}) if $self->Debug;
  shift @res;
  print Dumper({ResRes => \@res}) if $self->Debug;
  return {
	  Success => 1,
	  Interlingua => \@res,
	 };
}

sub ConvertCycAPIToInterlinguaHelper {
  my ($self,%args) = @_;
  my $debug = $self->Debug();
  my $item0 = $args{CycAPI};
  my $ref0 = ref($item0);
  if ($ref0 eq '') {
    if ($self->Debug) {
      print "------------\n";
      print $ref0."\n";
      print $item0."\n";
      print "------------\n";
    }
    return {
	    Success => 1,
	    Interlingua => $item0,
	   };
  } else {
    if ($self->Debug) {
      print "------------\n";
      print $ref0."\n";
      print $item0->toString."\n";
      print "------------\n";
    }
    print DumperQuote2({
			Ref0 => $ref0,
			String => $item0->toString(),
		       })."\n" if $self->Debug;
    my @res;
    if ($ref0 =~ /^System::Cyc::(OpenCyc|ResearchCyc(1_0)?|EnterpriseCyc)::Java::(CycAccess|CycLParserUtil)::org::opencyc::cycobject::CycSymbol$/) {
      return {
	      Success => 1,
	      Interlingua => $item0->toString(),
	     };
    } elsif ($ref0 =~ /^System::Cyc::(OpenCyc|ResearchCyc(1_0)?|EnterpriseCyc)::Java::(CycAccess|CycLParserUtil)::org::opencyc::cycobject::CycConstant$/) {
      return {
	      Success => 1,
	      Interlingua => $item0->cyclify(),
	     };
    } elsif ($ref0 =~ /^System::Cyc::(OpenCyc|ResearchCyc(1_0)?|EnterpriseCyc)::Java::(CycAccess|CycLParserUtil)::org::opencyc::cycobject::CycVariable$/) {
      return {
	      Success => 1,
	      Interlingua => Var($item0->toString),
	     };
    } elsif ($ref0 =~ /^System::Cyc::(OpenCyc|ResearchCyc(1_0)?|EnterpriseCyc)::Java::(CycAccess|CycLParserUtil)::org::opencyc::cycobject::CycNart$/) {
      my $res = $self->ConvertCycAPIToInterlinguaHelper
	(
	 # CycAPI => $item0->getFormula,
	 CycAPI => $item0->toDeepCycList,
	);
      if ($res->{Success}) {
	my $assertion;
	if (ref($res->{Interlingua}) eq 'ARRAY' and $res->{Interlingua}->[0] eq 'QUOTE' and scalar @{$res->{Interlingua}} == 2) {
	  $assertion = $res->{Interlingua}->[1];
	} else {
	  $assertion = $res->{Interlingua};
	}
	push @res, '#<', $assertion, '>';
      } else {
	print DumperQuote2({Res => $res})."\n" if $self->Debug;
      }
    } elsif ($ref0 =~ /^System::Cyc::(OpenCyc|ResearchCyc(1_0)?|EnterpriseCyc)::Java::(CycAccess|CycLParserUtil)::org::opencyc::cycobject::CycAssertion$/) {
      my $res = $self->ConvertCycAPIToInterlinguaHelper
	(
	 CycAPI => $item0->getFormula->second->first,
	);
      if ($res->{Success}) {
	my $assertion;
	if (ref($res->{Interlingua}) eq 'ARRAY' and $res->{Interlingua}->[0] eq 'QUOTE' and scalar @{$res->{Interlingua}} == 2) {
	  $assertion = $res->{Interlingua}->[1];
	} else {
	  $assertion = $res->{Interlingua};
	}
	push @res, '#<AS', $assertion, ':', $item0->getMt->toString, '>';
      } else {
	print DumperQuote2({Res => $res})."\n" if $self->Debug;
      }
    } elsif ($ref0 =~ /^System::Cyc::(OpenCyc|ResearchCyc(1_0)?|EnterpriseCyc)::Java::(CycAccess|CycLParserUtil)::org::opencyc::cycobject::CycList$/) {
      my $iterator0 = $item0->listIterator();
      while ($iterator0->hasNext) {
	my $item1 = $iterator0->next;
	# print Dumper({Item1 => $item1});
	my $res = $self->ConvertCycAPIToInterlinguaHelper
	  (
	   CycAPI => $item1,
	  );
	# print Dumper({Res => $res});
	if ($res->{Success}) {
	  if (ref($res->{Interlingua}) eq 'ARRAY' and $res->{Interlingua}->[0] eq 'QUOTE' and scalar @{$res->{Interlingua}} == 2) {
	      
	    push @res, $res->{Interlingua}->[1];
	  } else {
	    push @res, $res->{Interlingua};
	  }
	} else {
	  # FIXME: Throw error
	  print DumperQuote2({Res => $res})."\n" if $self->Debug;
	}
      }
      if (! $item0->isProperList) {
	push @res, ".";

	my $item2 = $item0->getDottedElement;
	my $res2 = $self->ConvertCycAPIToInterlinguaHelper
	  (
	   CycAPI => $item2,
	  );
	if ($res2->{Success}) {
	  if (ref($res2->{Interlingua}) eq 'ARRAY' and $res2->{Interlingua}->[0] eq 'QUOTE' and scalar @{$res2->{Interlingua}} == 2) {
	    push @res, $res2->{Interlingua}->[1];
	  } else {
	    push @res, $res2->{Interlingua};
	  }
	} else {
	  # FIXME: Throw error
	  print DumperQuote2({Res => $res2})."\n" if $self->Debug;
	}
      }
    } elsif ($ref0 =~ /^System::Cyc::(OpenCyc|ResearchCyc(1_0)?|EnterpriseCyc)::Java::(CycAccess|CycLParserUtil)::org::opencyc::cycobject::CycNaut$/) {
      my $iterator0 = $item0->cycListApiValue->listIterator();
      while ($iterator0->hasNext) {
	my $item1 = $iterator0->next;
	my $res = $self->ConvertCycAPIToInterlinguaHelper
	  (
	   CycAPI => $item1,
	  );
	if ($res->{Success}) {
	  if (ref($res->{Interlingua}) eq 'ARRAY' and $res->{Interlingua}->[0] eq 'QUOTE' and scalar @{$res->{Interlingua}} == 2) {
	    push @res, $res->{Interlingua}->[1];
	  } else {
	    push @res, $res->{Interlingua};
	  }
	} else {
	  print DumperQuote2({Res => $res})."\n" if $self->Debug;
	}
      }
    } elsif ($ref0 =~ /^System::Cyc::(OpenCyc|ResearchCyc(1_0)?|EnterpriseCyc)::Java::(CycAccess|CycLParserUtil)::org::opencyc::cycobject::CycFormulaSentence$/) {
      print Dumper({APIValue => $item0->cycListApiValue}) if $self->Debug;
      my $iterator0 = $item0->cycListApiValue->listIterator();
      while ($iterator0->hasNext) {
	my $item1 = $iterator0->next;
	my $res = $self->ConvertCycAPIToInterlinguaHelper
	  (
	   CycAPI => $item1,
	  );
	if ($res->{Success}) {
	  if (ref($res->{Interlingua}) eq 'ARRAY' and $res->{Interlingua}->[0] eq 'QUOTE' and scalar @{$res->{Interlingua}} == 2) {
	    push @res, $res->{Interlingua}->[1];
	  } else {
	    push @res, $res->{Interlingua};
	  }
	} else {
	  print DumperQuote2({Res => $res})."\n" if $self->Debug;
	}
      }
    }
    return {
	    Success => 1,
	    Interlingua => \@res,
	   };
  }
}

sub ConvertInterlinguaToCycLString {
  my ($self,%args) = @_;
  # print Dumper($args{Interlingua});
  my $res = $self->ConvertInterlinguaToCycLLightDomain
    (Interlingua => $args{Interlingua});
  # print Dumper($res);
  if ($res->{Success}) {
    my $structure = $res->{CycLLightDomain};
    print Dumper({Structure => $structure}) if $self->Debug;
    my $ref = ref($structure);
    if ($ref eq 'ARRAY') {
      my @list;
      my $i = 0;
      my $size = scalar @$structure;
      foreach my $formula (@$structure) {
	my $res = $self->Light->PrettyGenerate(Structure => $formula);
	if ($res =~ /^\(/) {
	  push @list, $res;
	  if ($i+1 < $size) {
	    push @list, "\n";
	  }
	} else {
	  push @list, $res;
	  if ($i+1 < $size) {
	    push @list, "\n";
	  }
	}
	++$i;
      }
      my $string = join("",@list);
      return {
	      Success => 1,
	      CycLString => $string,
	     };
    } else {
      print Dumper({Structure2 => $structure});
      return {
	      Success => 1,
	      CycLString => $structure,
	     };
    }
  } else {
    return $res;
  }
}

sub ConvertInterlinguaToCycLLightDomain {
  my ($self,%args) = @_;
  my @res;
  exists $args{Position} or $args{Position} = 0;
  my $interlingua = $args{Interlingua};
  my $type = ref $interlingua;
  if ($type eq "ARRAY") {
    my $i = 0;
    foreach my $subdomain (@$interlingua) {
      my $res = $self->ConvertInterlinguaToCycLLightDomain
	(
	 Interlingua => $subdomain,
	 Position => $i++,
	);
      if ($res->{Success}) {
	push @res, $res->{CycLLightDomain};
      } else {
	return $res;
      }
    }
  } elsif ($type eq "GLOB") {
    return {
	    Success => 1,
	    CycLLightDomain => TermIsVariable($interlingua),
	   };
  } else {
    # this is a string
    if (exists $self->ConstantLookup->{$interlingua}) {
      return {
	      Success => 1,
	      CycLLightDomain => $self->ConstantLookup->{$interlingua},
	     };
    } elsif ($args{Position} == 0) {
      # if this is the first place item, and it doesn't have cycl notation, add it, and add it to the the table????
      # encode it to a cycl item and add to the constant lookup
      my $res = $self->EncodeConstant
	(
	 Constant => $interlingua,
	);
      if ($res->{Success}) {
	$self->ConstantLookup->{$interlingua} = $res->{Encoding};
	return {
		Success => 1,
		CycLLightDomain => $res->{Encoding},
	       };
      } else {
	return $res;
      }
    } else {
      # FIXME: we need to handle the case of quoted strings
      return {
	      Success => 1,
	      CycLLightDomain => $interlingua,
	     };
    }
  }
  return {
	  Success => 1,
	  CycLLightDomain => \@res,
	 };
}

sub ConvertInterlinguaToCyclifiedString {
  my ($self,%args) = @_;
  my $res1 = $self->ConvertInterlinguaToCycLString
    (
     Interlingua => $args{Interlingua},
    );
  if ($res1->{Success}) {
    print Dumper({Res1 => $res1}) if $self->Debug;
    my $res2 = $self->ConvertCycLStringToCycAPI
      (
       ResearchCycLString => $res1->{CycLString},
       # FIXME: is this correct?
       ResearchCyc1_0LString => $res1->{CycLString},
      );
    print Dumper({Res2 => $res2}) if $self->Debug;
    if ($res2->{Success}) {
      return {
	      Success => 1,
	      Output => $res2->{'CycAPI'}->cyclify(),
	     };
    }
  }
}

sub EncodeConstant {
  my ($self,%args) = @_;
  my @res;
  my $constant = $args{Constant};
  # my $encoding = encode_base64($constant);
  my $encoding = $constant;
  chomp $encoding;
  return {
	  Success => 1,
	  Encoding => $encoding,
	 };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
