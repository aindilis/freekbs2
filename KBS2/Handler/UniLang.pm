package KBS2::Handler::UniLang;

use base qw(KBS2::Handler);

use PerlLib::MySQL;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / DBs /

  ];

sub init {
  my ($self,%args) = @_;
  $self->DBs({});
}

sub ProcessMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};
  my $d = $m->Data;
  my $command = $d->{Command};
  if ($command =~ /^(lookup-entry)$/) {
    my $database = $d->{Database};
    my $table = $d->{Table};
    my $field = $d->{Field};
    my $item = $d->{Item};
    my $search = $d->{Search};
    chomp $search;
    $search =~ s/^\W+//;
    $search =~ s/\W+$//;
    if (! exists $self->DBs->{$database}) {
      $self->DBs->{$database} = PerlLib::MySQL->new
	(DBName => $database);
    }
    my $quotedsearch = $self->DBs->{$database}->Quote($search);
    $quotedsearch =~ s/^'//;
    $quotedsearch =~ s/'$//;
    my $statement = "select * from $table where $field like '%$quotedsearch%'";
    my $res = $self->DBs->{$database}->Do
      (Statement => $statement);
    if ((scalar keys %$res) >= 1) {
      my @reskeys = keys %$res;
      $UNIVERSAL::kbs2->ReturnAnswer
	(
	 Message => $args{Message},
	 Result => {
		    Success => 1,
		    Result => $res->{$reskeys[0]}->{$item},
		   },
	);
    }
  }
}

1;
