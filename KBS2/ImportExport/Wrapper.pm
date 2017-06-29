package KBS2::ImportExport::Wrapper;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(Quote QuoteProlog);

# use PerlLib::SwissArmyKnife;

use KBS2::ImportExport;

{
  $wrapper = KBS2::ImportExport->new;
}

sub QuoteProlog {
  my ($item) = @_;
  Quote(
	Input => $item,
	InputType => 'Interlingua',
	OutputType => 'Prolog',
       );
}

sub Quote {
  my (%args) = @_;
  my $res1 = $wrapper->Convert
    (
     Input => $args{Input},
     InputType => $args{InputType},
     OutputType => $args{OutputType},
    );
  if ($res1->{Success}) {
    return $res1->{Output};
  } else {
    # throw ERROR
  }
}

1;
