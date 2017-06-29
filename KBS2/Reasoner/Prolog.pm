package KBS2::Reasoner::Prolog;




# FIXME: Add the ability to assert to the KB without checking
# consistency or checking it really quickly using Prolog, so it runs
# faster.  Find ways of having it load faster, such as QLF, with
# timestamping and change logs.

# do it directly by using perl_call or whatever instead of running
# through UniLang, except for of course the unilang interface to
# FreeKBS2 external API.  See if even that can be bypassed for added
# speed, especially within FLP and other related projects.





# see Formalog::Util::Prolog;
# see Formalog::Multi;
# see Formalog::Multi::Agent;
# see Formalog::Multi::Agent::Yaswi;

# FIXME: Far from finished

use base qw(KBS2::Reasoner);

use Formalog::Multi::Test;
use KBS2::ImportExport;
use KBS2::Util;
use PerlLib::SwissArmyKnife;
use UniLang::Agent::Agent;
use UniLang::Util::Message;

use UniLang::Util::TempAgent;

use Language::Prolog::Yaswi ':query', ':load', ':interactive', ':run';

use Moose;

has 'ImportExport' =>
  (
   is => 'rw',
   isa => 'KBS2::ImportExport',
   default => sub {
     KBS2::ImportExport->new();
   },
  );
has 'Debug' => (is => 'rw', isa => 'Bool');
has 'FormalogMultiTest' =>
  (
   is => 'rw',
   isa => 'Formalog::Multi::Test',
   default => sub {
     Formalog::Multi::Test->new();
   },
  );
# has 'TempAgent' =>
#   (
#    is => 'rw',
#    isa => 'UniLang::Util::TempAgent',
#    default => sub {
#      UniLang::Util::TempAgent->new
# 	 (
# 	  Name => 'KBS2_Reasoner_Prolog_Client',
# 	  ReceiveHandler => sub {
# 	    $self->FormalogMultiTest->ProcessMessage
# 	      (Message => $args{Message})
# 	    },
# 	 ),
#        },
#   );

sub BUILD {
  my ($self,$args) = @_;
  $self->FormalogMultiTest->Execute
    (
     AddNewAgentArgs => {
			 AgentName => 'KBS2_Reasoner_Prolog',
			 YaswiName => 'KBS2_Reasoner_Prolog_Yaswi',
			 YaswiData => {
				       # Context => '',
				       # FileNameToLoad => '/var/lib/myfrdcsa/codebases/minor/free-fluxplayer/swipl/calendaring',
				       FileNameToLoad => '/var/lib/myfrdcsa/codebases/internal/freekbs2/formalog/kbs2_reasoner_prolog.pl',
				       # Before => '',
				       # During => '',
				       # After => '',
				      },
			},
    );
}

sub StartServer {
  my ($self,%args) = @_;
  # FIXME: don't think this needs to be implemented
  swi_cleanup();
}

sub RestartServer {
  my ($self,%args) = @_;
  # FIXME: this may have to be implemented
  swi_cleanup();
}

sub Assert {
  my ($self,%args) = @_;

  return $self->SendQuery
    (
     Type => "assert",
     Formula => $args{Formula},
     Theory => $args{Theory},
    );
}

sub Unassert {
  my ($self,%args) = @_;
  # I don't think we need to do anything
  if (0) {
    return $self->SendQuery
      (
       Type => "unassert",
       Formula => $args{Formula},
       Theory => $args{Theory},
      );
  } else {
    return {
	    Result => "unasserted",
	   };
  }
}

sub Query {
  my ($self,%args) = @_;
  return $self->SendQuery
    (
     Type => "query",
     Formula => $args{Formula},
     Theory => $args{Theory},
     Attributes => $args{Attributes},
    );
}

sub SendQuery {
  my ($self,%args) = @_;
  my $type = $args{Type};

  print Dumper({SendQueryArgs => \%args}) if $self->Debug;

  # NOW, YOU HAVE TO LOAD EVERYTHING IN
  my $reason;
  my $res1 = $self->Resources->ImportExport->Convert
    (
     InputType => 'Interlingua',
     OutputType => 'Prolog',
     Input => $args{Theory},
    );
  if ($res1->{Success}) {
    my $res2 = $self->MyImportExport->Convert
      (
       Input => [$args{Formula}],
       InputType => "Interlingua",
       OutputType => "Prolog",
      );

    if ($res2->{Success}) {
      print Dumper(Attributes => $args{Attributes});
      swi_inline($res1->{Output}."\n".$res2->{Output});
      my @result;
      try {
	swi_set_query(page_read_p(Doc,Page));
	while (swi_next) {
	  push @result,
	    {
	     Doc => swi_var(Doc),
	    };
	}
      }
      catch {
      }
      finally {
      };
      print Dumper({QueryResult => \@result}) if $self->Debug();
      # FIXME: translate the query apropriately
      return
	{
	 Success => 1,
	 Result => \@result,
	};
    } else {
      $reason = "Could not convert query to Prolog";
    }
  } else {
    $reason = "Could not convert theory to Prolog";
  }
  return {
	  Success => 0,
	  Reasons => $reason,
	 };
}

1;

1;
