package KBS2;

use BOSS::Config;
use KBS2::HandlerManager;
use KBS2::ImportExport;
use KBS2::StoreManager;
use KBS2::Util;
use MyFRDCSA;

use Data::Dumper;

our $VERSION = '2.00';

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config MyStoreManager MyImportExport MyHandlerManager /

  ];

sub init {
  my ($self,%args) = @_;
  $specification = "
	-u [<host> <port>]	Run as a UniLang agent

	-w			Require user input before exiting
";
  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"freekbs2");
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ?
       $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ?
       $conf->{-u}->{'<port>'} : "9000");
  }
  $self->MyStoreManager
    (KBS2::StoreManager->new());
  $self->MyImportExport
    (KBS2::ImportExport->new());
  $self->MyHandlerManager
    (KBS2::HandlerManager->new());
}

sub Execute {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    # enter in to a listening loop
    while (1) {
      $UNIVERSAL::agent->Listen(TimeOut => 10);
    }
  }
  if (exists $conf->{'-w'}) {
    Message(Message => "Press any key to quit...");
    my $t = <STDIN>;
  }
}

sub ProcessMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};

  # look at the data segment and send
  my $it = $m->Contents;
  if ($it =~ /^echo\s*(.*)/) {
    $UNIVERSAL::agent->SendContents
      (Contents => $1,
       Receiver => $m->{Sender});
  } elsif ($it =~ /^(quit|exit)$/i) {
    $UNIVERSAL::agent->Deregister;
    exit(0);
  }
  my $d = $m->Data;
  my ($command,$method,$database,$reasoner,$context,$asserter,$id,$constraints,$flags,$outputtype,$data) =
    (
     $d->{Command} || "echo",
     $d->{Method} || "MySQL",
     $d->{Database} || "freekbs2",
     $d->{Reasoner},
     $d->{Context} || "default",
     $d->{Asserter} || "guest",
     $d->{ID} || -1,
     $d->{Constraints} || {},
     $d->{Flags} || {},
     $d->{OutputType},
     $d->{Data} || {},
    );

  print Dumper({D => $d}) if $UNIVERSAL::debug;

  # convert to formulae from string
  my $formulae;
  if (exists $d->{Formula}) {
    $formulae = [$d->{Formula}];
  } elsif (exists $d->{Formulae}) {
    $formulae = $d->{Formulae};
  } elsif ((exists $d->{FormulaString}) or (exists $d->{FormulaeString})) {
    my $string = "";
    if (exists $d->{FormulaString}) {
      $string .= $d->{FormulaString};
    }
    if (exists $d->{FormulaeString}) {
      $string .= $d->{FormulaeString};
    }
    # in the future, implement the ability to auto recognize which
    # format it is
    if ($method =~ /^MySQL$/i) {
      # determine which format this is in, then convert it to
      # interlingua
      print Dumper({String =>  $string});
      my $res = $self->MyImportExport->Convert
	(
	 Input => $string,
	 InputType => $d->{InputType} || "Emacs String",
	 OutputType => "Interlingua",
	);
      if ($res->{Success}) {
	$formulae = $res->{Output};
      }
    }
  } else {
    # no formula, return an error? no there are some that don't need this
  }

  print Dumper({
		In => "KBS2",
		Formulae => $formulae,
	       });
  my $store = join(":",($method,$database,$context));

  if ($command =~ /^(assert|unassert|query|query-cyclike|get-id)$/i) {
    # load the store
    # assert the information into the appropriate
    # convert here

    my $formula = $formulae->[0];

    my $type = "Exists";
    if (VariablesInFormula
	(Formula => $formula)) {
      $type = "Models";
    }
    my $res = $self->MyStoreManager->Manage
      (
       Flags => $flags,
       Method => $method,
       Database => $database,
       Reasoner => $reasoner,
       Context => $context,
       Asserter => $asserter,
       Command => $command,
       Type => $type,
       Formula => $formula,
       OutputType => $outputtype,
       Data => $data,
      );
    $self->ReturnAnswer
      (
       # QueryAgentReply => 1,
       Result => $res,
       Message => $m,
      );
  } elsif ($command =~ /^(all-asserted-knowledge|unassert-by-id|rename-context|clear-context|remove-context|restart-reasoner)$/i) {
    my $res = $self->MyStoreManager->Manage
      (
       Flags => $flags,
       Method => $method,
       Database => $database,
       Reasoner => $reasoner,
       Context => $context,
       Asserter => $asserter,
       Command => $command,
       Search => $constraints->{Search},
       Date => $constraints->{Date},
       ID => $id,
      );
    $self->ReturnAnswer
      (
       Result => $res,
       Message => $m,
      );
    # } elsif ($command =~ /^(list-predicates|list-contexts|lookup-assertion|summarize-contents)$/i) {
  } elsif ($command =~ /^(list-contexts)$/i) {
    my $res = $self->MyStoreManager->Manage
      (
       Flags => $flags,
       Method => $method,
       Database => $database,
       Reasoner => $reasoner,
       Context => $context,
       Asserter => $asserter,
       Command => $command,
       Search => $constraints->{Search},
       Date => $constraints->{Date},
       ID => $id,
      );
    $self->ReturnAnswer
      (
       Result => $res,
       Message => $m,
      );
    # } elsif ($command =~ /(lookup-entry|fes-get-entries|search-terms)/) {
  } elsif ($command =~ /^importexport$/i) {
    my $keys =
      {
       Input => $m->Data->{Input},
       OutputType => $m->Data->{OutputType},
      };
    if (! exists $m->{Data}->{InputType}) {
      if (exists $m->{Data}->{GuessInputType}) {
	$keys->{GuessInputType} = 1;
      } else {
	# FIXME: complain
      }
    } else {
      $keys->{InputType} = $m->Data->{InputType},
    }
    my $result = $self->MyImportExport->Convert
      (
       %$keys,
      );
    print Dumper({Result => $result});
    $UNIVERSAL::agent->SendContents
      (
       Receiver => $m->Sender,
       Data => {
		Result => $result,
	       },
      );
  } elsif (exists $m->Data->{_RPC_Sub}) {
    my $rpc_sub = $m->Data->{_RPC_Sub};
    my $sub = eval "sub {\$self->MyEnju->$rpc_sub(\@_)}";
    $UNIVERSAL::agent->SendContents
      (
       Receiver => $m->Sender,
       Data => {
		_DoNotLog => 1,
		_RPC_Results => [$sub->(@{$m->Data->{_RPC_Args}})],
	       },
      );
  } else {
    # look at all the additional handlers
    $self->MyHandlerManager->ProcessMessage
      (
       Message => $m,
      );
  }
}

sub ReturnAnswer {
  my ($self,%args) = @_;
  $UNIVERSAL::agent->QueryAgentReply
    (
     Message => $args{Message},
     Data => {
	      _DoNotLog => 1,
	      Result => $args{Result}->{Result},
	     },
    );
}

=head1 NAME

KBS2 - Free Knowledge Based System Version 2

=head1 SYNOPSIS

  use KBS2::Client;

  use Data::Dumper;

  # Create a new UniLang Client to talk to FreeKBS2

  my $client = KBS2::Client->new
   (
    Context => "test",
   );

  $client->Send
   (
    Command => "assert",
    FormulaString => '("isa" "FreeKBS2" "FRDCSA Internal Codebase")',
   );

   my @res = $client->Send
   (
    Command => "query",
    FormulaString => '("isa" ?X ?Y)',
   );

   print Dumper(\@res);

=head1 DESCRIPTION

This is really a description of the KBS2::Client module.

The rest of this is just filler from another module for now.

This module provides low-level control of a LEGO NXT brick over bluetooth
using the Direct Commands API.  This API will not enable you to run programs
on the NXT, rather, it will connect to the NXT and issue real-time commands
that turn on/off motors, retrieve sensor values, play sound, and more.

Users will leverage this API to control the NXT directly from an external box.

This is known to work on Linux. Other platforms are currently untested,
though it should work on any system that has the Net::Bluetooth module.

=head1 MANUAL

There is a manual for this module with an introduction, tutorials, plugins,
FAQ, etc.  See L<LEGO::NXT::Manual>.

=head1 SUPPORT

If you would like to get some help join the #lego-nxt IRC chat room
on the MagNET IRC network (the official perl IRC network).  More
information at:

L<http://www.irc.perl.org/>

=head1 PLUGINS

LEGO::NXT supports the ability to load plugins.

  use LEGO::NXT qw( Scorpion );

Plugins provide higher level and more sophisticated means of handling
your NXT.  Likely you will want to use a plugin if you want to control
your NXT as the methods in LEGO::NXT itself are very low level and
tedious to use by themselves.

Please see L<LEGO::NXT::Manual::Plugins> for more details about how to
use plugins (and write your own!) as well as what plugins are available
to you.

=cut

1;
