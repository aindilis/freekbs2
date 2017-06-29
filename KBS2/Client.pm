package KBS2::Client;

use KBS2::Client::Response;
use KBS2::ImportExport;

use UniLang::Agent::Agent;
use UniLang::Util::Message;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyAgent Name Data Method Database Context Asserter Debug
   MyImportExport Verbose /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Name($args{Name} || "KBS2-client-".rand());
  $self->Method
    ($args{Method} || "MySQL");
  $self->Database
    ($args{Database} || "freekbs2");
  $self->Context
    ($args{Context} || "default");
  $self->Asserter
    ($args{Asserter} || "guest");
  $self->Debug($args{Debug});
  $self->Verbose($args{Verbose} || 0);
  $self->MyAgent
    (UniLang::Agent::Agent->new
     (
      Name => $self->Name,
      ReceiveHandler => sub {$self->Receive(@_)},
      # Debug => 1,
     ));
  $self->MyAgent->DoNotDaemonize(1);
  my $host = $args{Host} || (defined $conf->{-u}->{'<host>'} ? $conf->{-u}->{'<host>'} : "localhost");
  my $port = $args{Port} || (defined $conf->{-u}->{'<port>'} ? $conf->{-u}->{'<port>'} : "9000");
  $self->MyAgent->Register
    (
     Host => $host,
     Port => $port,
    );
  $self->MyImportExport
    (KBS2::ImportExport->new());
}

sub Receive {
  my ($self,%args) = @_;
  $self->Data(\%args);
  $self->MyAgent->UnListen;
}

sub Send {
  my ($self,%args) = @_;
  print Dumper({Args => \%args}) if $self->Verbose;
  my $command = $args{Command} || undef;
  my $method = $args{Method} || $self->Method;
  my $database = $args{Database} || $self->Database;
  my $context = $args{Context} || $self->Context;
  my $asserter = $args{Asserter} || $self->Asserter;
  my $type = $args{Type};
  my $flags = $args{Flags} || {};
  my $contents;
  my $formulae;
  if ($args{Assert}) {
    $command = "assert";
    my $res = $self->MyImportExport->Convert
      (
       Input => $args{Assert},
       InputType => $args{InputType},
       OutputType => "Interlingua",
      );
    if ($res->{Success}) {
      $formulae = $res->{Output};
    }
  } elsif ($args{Unassert}) {
    $command = "unassert";
    my $res = $self->MyImportExport->Convert
      (
       Input => $args{Unassert},
       InputType => $args{InputType},
       OutputType => "Interlingua",
      );
    if ($res->{Success}) {
      $formulae = $res->{Output};
    }
  } elsif ($args{Query}) {
    $command = "query";
    my $res = $self->MyImportExport->Convert
      (
       Input => $args{Query},
       InputType => $args{InputType},
       OutputType => "Interlingua",
      );
    if ($res->{Success}) {
      $formulae = $res->{Output};
    }
  } elsif ($args{RenameContext}) {
    $command = "rename-context",
  } elsif ($args{ClearContext}) {
    $command = "clear-context",
  } elsif ($args{RemoveContext}) {
    $command = "remove-context",
  }
  my $formula;
  if (ref $formulae eq "ARRAY" and scalar @$formulae) {
    $formula = $formulae->[0];
  }
  my %tosend = (
		Receiver => "KBS2",
		Data => {
			 _DoNotLog => 1,
			 Command => $command,
			 Formula => $formula,
			 Method => $method,
			 Database => $database,
			 Context => $context,
			 Asserter => $asserter,
			 Quiet => $args{Quiet},
			 OutputType => $args{OutputType},
			 Flags => $args{Flags},
			 Data => $args{Data},
			 Type => $type,
			 Force => $args{Force},
			},
	       );
  print Dumper(\%tosend) if $self->Verbose;
  if ($self->Debug) {
    print "Debug ON: Not Sending.\n";
  } else {
    print "Sending.\n" if $self->Verbose;
    if (1 or $args{QueryAgent}) {
      print Dumper({ToSend => \%tosend}) if $self->Verbose;
      print Dumper({MyAgent => $self->MyAgent}) if $self->Verbose;
      my $res = $self->MyAgent->QueryAgent
	(%tosend);
      if (exists $args{ResultType} and $args{ResultType} eq "object") {
	# create a client response object
	my $object = KBS2::Client::Response->new
	  (
	   Message => $res,
	  );
	return $object;
      } else {
	return $res;
      }
    } else {
      my $res = $self->MyAgent->SendContents
	(%tosend);
    }
  }
}

sub RenameContext {
  my ($self, %args) = @_;
  $self->Send
    (
     QueryAgent => 1,
     Command => "rename-context",
     Context => $args{Context},
     Data => $args{Data},
    );
}

sub ClearContext {
  my ($self, %args) = @_;
  $self->Send
    (
     QueryAgent => 1,
     Command => "clear-context",
     Context => $args{Context},
    );
}

sub RemoveContext {
  my ($self, %args) = @_;
  $self->Send
    (
     QueryAgent => 1,
     Command => "remove-context",
     Context => $args{Context},
    );
}

1;
