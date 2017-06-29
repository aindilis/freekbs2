package KBS2::ImportExport::Mod::KIF;

use KBS2::Util;
use Manager::Misc::Light2;

use IO::File;

use Data::Dumper;
use File::Slurp;
use MIME::Base64;
use URI::Escape qw(uri_escape_utf8 uri_unescape);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyLight Types Debug EscapeChars Mappings IMappings /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug} || $UNIVERSAL::debug);
  $self->MyLight
    (Manager::Misc::Light2->new);
  $self->Types
    ({
      "Interlingua" => 1,
      "KIF Light Domain" => 1,
      "KIF String" => 1,
     });
  # $self->EscapeChars
  # ('^a-zA-Z0-9!&*\$+-./<=>?@~');
  $self->EscapeChars
    ('^a-zA-Z0-9-');
  $self->Mappings
    ({
      "=>" => "implies",
      # "<=>" => "<=>",

      ">" => ">",
      ">=" => ">=",

      # "<=" => "<=",
      # "<" => "<",

      "equal" => "equal",

      # # "=" => "equals",
      # # "<=" => "only-if",
      # # "<=>" => "iff",
      # # "+" => "plus",
      # # "-" => "minus",
     });
  $self->IMappings({});
  foreach my $key (keys %{$self->Mappings}) {
    $self->IMappings->{$self->Mappings->{$key}} = $key;
  }
  # $self->IMappings->{"is"} = "=";
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
  } elsif ($args{InputType} eq "KIF String") {
    my $res = $self->ConvertKIFStringToInterLingua
      (
       KIFString => $args{Input},
      );
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Interlingua => $res->{Interlingua},
	     };
    } else {
      return $res;
    }
  } elsif ($args{InputType} eq "KIF Light Domain") {
    my $res = $self->ConvertKIFLightDomainToInterlingua
      (
       Domain => $args{Input},
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
  } elsif ($args{OutputType} eq "KIF String") {
    my $res = $self->ConvertInterlinguaToKIFString
      (
       Interlingua => $args{Interlingua},
      );
    print Dumper({RES932523 => $res}) if $self->Debug;
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Output => $res->{KIFString},
	     };
    } else {
      return $res;
    }
  } elsif ($args{OutputType} eq "KIF Light Domain") {
    my $res = $self->ConvertInterlinguaToKIFLightDomain
      (Interlingua => $args{Interlingua});
    if ($res->{Success}) {
      return {
	      Success => 1,
	      Output => $res->{KIFLightDomain},
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

sub ConvertKIFStringToInterLingua {
  my ($self,%args) = @_;
  my $res = $self->MyLight->Parse
    (Contents => $args{KIFString});
  if ($res->{Success}) {
    my $domain = $res->{Domain};
    # now we have to translate the stuff
    my $res2 = $self->ConvertKIFLightDomainToInterlingua(Domain => $domain);
    if ($res2->{Success}) {
      return {
	      Success => 1,
	      Interlingua => $res2->{Interlingua},
	     };
    } else {
      return $res2;
    }
  } else {
    return $res;
  }
}



sub ConvertKIFLightDomainToInterlingua {
  my ($self,%args) = @_;
  my @res;
  my $domain = $args{Domain};
  my $type = ref $domain;
  if ($type eq "ARRAY") {
    # check for the special case of negative numbers
    #     if (defined $self->Mappings->{"-"} and (scalar @$domain) == 2) {
    #       if ($domain->[0] eq "-" and $domain->[1] =~ /^\d+$/) {
    # 	return {
    # 		Success => 1,
    # 		Interlingua => "-".$domain->[1],
    # 	       };
    #       }
    #     }
    my $i = 0;
    foreach my $subdomain (@$domain) {
      my $res = $self->ConvertKIFLightDomainToInterlingua
	(
	 Domain => $subdomain,
	 Position => $i++,
	);
      if ($res->{Success}) {
	push @res, $res->{Interlingua};
      } else {
	return $res;
      }
    }
  } else {
    if ($domain =~ /^\?(.+)$/) {
      return {
	      Success => 1,
	      Interlingua => \*{"::?$1"},
	     };
    } else {
      my $res = $self->DecodeConstant
	(
	 Constant => $domain,
	 Position => $args{Position},
	);
      my $retval;
      if ($res->{Success}) {
	$retval = $res->{Constant};
      } else {
	$retval = $domain;
      }
      if ($retval =~ /^(cyc-)(.+)$/) {
	my $rest = $2;
	my $res = $self->DecodeConstant
	  (
	   Constant => $rest,
	   Position => $args{Position} + 4,
	  );
	if ($res->{Success}) {
	  $retval = '#$'.$rest;
	}
      }
      return {
	      Success => 1,
	      Interlingua => $retval,
	     };
    }
  }
  return {
	  Success => 1,
	  Interlingua => \@res,
	 };
}

sub ConvertInterlinguaToKIFString {
  my ($self,%args) = @_;
  # print Dumper($args{Interlingua});
  my $res = $self->ConvertInterlinguaToKIFLightDomain
    (
     Interlingua => $args{Interlingua},
    );
  if ($res->{Success}) {
    my $structure = $res->{KIFLightDomain};
    my @list;
    foreach my $formula (@$structure) {
      push @list, $self->MyLight->PrettyGenerate
	(
	 PrettyPrint => 0,
	 Structure => $formula,
	);
    }
    return {
	    Success => 1,
	    KIFString => join("\n",@list),
	   };
  } else {
    return $res;
  }
}

sub ConvertInterlinguaToKIFLightDomain {
  my ($self,%args) = @_;
  my @res;
  my $interlingua = defined $args{Interlingua} ? $args{Interlingua} : "";
  my $type = ref $interlingua;
  if ($type eq "ARRAY") {
    my $i = 0;
    foreach my $subdomain (@$interlingua) {
      my $res = $self->ConvertInterlinguaToKIFLightDomain
	(
	 Interlingua => $subdomain,
	 Position => $i++,
	);
      if ($res->{Success}) {
	push @res, $res->{KIFLightDomain};
      } else {
	return $res;
      }
    }
  } elsif ($type eq "GLOB") {
    return {
	    Success => 1,
	    KIFLightDomain => TermIsVariable($interlingua),
	   };
  } else {
    # this is a string
    if ($interlingua =~ /^(\#\$)(.+)$/) {
      my $rest = $2;
      my $res = $self->EncodeConstant
	(
	 Constant => $rest,
	 Position => $args{Position} + 2,
	);
      if ($res->{Success}) {
	$interlingua = 'cyc-'.$res->{Encoding};
      } else {
	$interlingua = 'cyc-'.$rest;
      }
      return {
	      Success => 1,
	      KIFLightDomain => $interlingua,
	     };
    } else {
      # we need to handle the case of quoted strings
      my $res = $self->EncodeConstant
	(
	 Constant => $interlingua,
	 Position => $args{Position},
	);
      my $retval;
      if ($res->{Success}) {
	$retval = $res->{Encoding};
      } else {
	$retval = $interlingua;
      }
      return {
	      Success => 1,
	      KIFLightDomain => $retval,
	     };
    }
  }
  return {
	  Success => 1,
	  KIFLightDomain => \@res,
	 };
}

# Maybe there could be a knowledge interface format between a
# thesaurus and a dictionary for mapping out cross domain relations or
# alternative route mathematics, route being pathway, journey, guided
# tour, trail, chain, sequence.


sub EncodeConstant {
  my ($self,%args) = @_;
  my $constant = $args{Constant};
  my $fh = IO::File->new();
  $fh->open(">>/tmp/1.txt");
  print $fh "<$constant>\n";
  $fh->close();

  # translate key items here
  if ($args{Position} == 0) {
    foreach my $key (keys %{$self->IMappings}) {
      if ($args{Constant} eq $key) {
	return {
		Success => 1,
		Encoding => $self->IMappings->{$key},
	       };
      }
    }
  }
  my @res;
  my $escapechars = $self->EscapeChars;
  my $encoding;
  #if (defined $self->Mappings->{"-"} and $constant =~ /^\-(\d+)$/) {
  # $encoding = ["-",$1];
  # } els
  if ($constant =~ /^\d+$/) {
    $encoding = $constant;
  } elsif ($constant =~ /^(.)(.+)$/) {
    my $firstchar = $1;
    my $rest = $2;
    $encoding = uri_escape_utf8($firstchar,'^a-zA-Z').uri_escape_utf8($rest,$escapechars);
  } else {
    $encoding = uri_escape_utf8($constant,$escapechars);
  }
  $encoding =~ s/\%/_/g;
  $encoding =~ s/^_/kbs2_kif_quote_/;
  # my $encoding = encode_base64($constant);
  return {
	  Success => 1,
	  Encoding => $encoding,
	 };
}

sub DecodeConstant {
  my ($self,%args) = @_;
  # print Dumper(\%args);
  my $constant = $args{Constant};
  # translate key items here

  if (exists $args{Position} and ($args{Position} == 0)) {
    if ($args{Position} == 0) {
      foreach my $key (keys %{$self->Mappings}) {
	if ($args{Constant} eq $key) {
	  return {
		  Success => 1,
		  Constant => $self->Mappings->{$key},
		 };
	}
      }
    }
  }

  my @res;
  $constant =~ s/^kbs2_kif_quote_/_/;
  $constant =~ s/_/\%/g;
  my $escapechars = $self->EscapeChars;
  my $encoding = [uri_unescape($constant,$escapechars)]->[0];
  # my $encoding = decode_base64($constant);
  return {
	  Success => 1,
	  Constant => $encoding,
	 };
}

1;

# upper ::= A | B | C | D | E | F | G | H | I | J | K | L | M | 
#               N | O | P | Q | R | S | T | U | V | W | X | Y | Z

#   lower ::= a | b | c | d | e | f | g | h | i | j | k | l | m | 
#               n | o | p | q | r | s | t | u | v | w | x | y | z

#     digit ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9

#     alpha ::= ! | $ | % | & | * | + | - | . | / | < | = | > | ? |
#               @ | _ | ~ |

#     special ::= " | # | ' | ( | ) | , | \ | ^ | `

#     white ::= space | tab | return | linefeed | page

# my $upper = "[A-Z]";
# my $lower = "[a-z]";
# my $digit = "\d";
# my $alpha = '(\!|\$|\%|\&|\*|\+|\-|\.|\/|\<|\=|\>|\?|\@|\_|\~)';
# my $special = '(\"|\#|\\\'|\(|\)|\,|\\|\^|\`)';
# my $white = "\s";
