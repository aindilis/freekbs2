package KBS2::StoreManager;

use KBS2::Store::MySQL;
use KBS2::Rules;
use PerlLib::Collection;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Stores MyRules /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Stores
    (PerlLib::Collection->new
     (Type => "KBS2::Store"));
  $self->Stores->Contents({});
  $self->MyRules(KBS2::Rules->new);
}

sub Manage {
  my ($self,%args) = @_;
  my ($method,$database,$context,$asserter) =
    (
     $args{Method} || "MySQL",
     $args{Database} || "freekbs2",
     $args{Context} || "default",
     $args{Asserter} || "guest",
    );

  my $methodcolondb = "$method:$database";
  if (! exists $self->Stores->Contents->{$methodcolondb}) {
    # have to create a new store
    if ($method eq "MySQL") {
      $self->Stores->Contents->{$methodcolondb} =
	KBS2::Store::MySQL->new
	  (
	   Reasoner => $args{Reasoner},
	   Database => $database,
	  );
    } else {
      return {
	      Success => 0,
	      Reasons => {
			  "Unimplemented method <<<$method>>>" => 1,
			 },
	     };
    }
  }
  my $store = $self->Stores->Contents->{$methodcolondb};

  # now go ahead and using this run the operation
  if ($args{Command} =~ /^assert$/i) {
    my $res = $store->Assert
      (
       Context => $context,
       Formula => $args{Formula},
       Asserter => $asserter,
       Flags => $args{Flags},
      );
    if ($res) {
      # run hooks on this
      $self->MyRules->Apply
	(
	 Context => $context,
	 Formula => $args{Formula},
	 Asserter => $asserter,
	 Action => "assert",
	);
    }
    return {
	    Result => $res,
	   };
  } elsif ($args{Command} =~ /^query$/i) {
    my $res = $store->Query
      (
       Context => $context,
       Type => $args{Type},
       Formula => $args{Formula},
       Asserter => $asserter,
       Flags => $args{Flags},
      );
    if ($res) {
      my $res = $self->MyRules->Apply
	(
	 Context => $context,
	 Type => $args{Type},
	 Formula => $args{Formula},
	 Asserter => $asserter,
	 Action => "query",
	);
    }
    return {
	    Result => $res,
	   };
  } elsif ($args{Command} =~ /^query-cyclike$/i) {
    return $store->Query
      (
       Context => $context,
       Type => $args{Type},
       Formula => $args{Formula},
       Style => "cyclike",
       Asserter => $asserter,
       Flags => $args{Flags},
      );
  } elsif ($args{Command} =~ /^unassert$/i) {
    my $res = $store->UnAssert
		  (
		   Context => $context,
		   Formula => $args{Formula},
		   Asserter => $asserter,
		  );
    if ($res) {
      $self->MyRules->Apply
		  (
		   Context => $context,
		   Formula => $args{Formula},
		   Asserter => $asserter,
		   Action => "unassert",
		  );
    }
    return {
	    Result => $res,
	   };
  } elsif ($args{Command} =~ /^get-id$/i) {
    return Dumper($store->Query
		  (
		   Context => $context,
		   Type => "GetID",
		   Formula => $args{Formula},
		   Asserter => $asserter,
		  ));
  } elsif ($args{Command} =~ /^unassert-by-id$/i) {
    my $res = $store->Remove
		  (
		   ID => $args{Search},
		   Asserter => $asserter,
		  );
    if ($res) {
      $self->MyRules->Apply
		  (
		   ID => $args{Search},
		   Asserter => $asserter,
		   Action => "unassert",
		  );
    }
    return {
	    Result => $res,
	   };
  # } elsif ($args{Command} =~ /^all-asserted-knowledge.*$/i) { # why was this with the .*$
  } elsif ($args{Command} =~ /^all-asserted-knowledge$/i) { 
    print Dumper({Date => $args{Date}});
    my $res = $store->AllAssertedKnowledge
		  (
		   Context => $context,
		   Search => $args{Search},
		   Asserter => $asserter,
		   Date => $args{Date},
		  );
    return {
	    Result => $res,
	   };
  } elsif ($args{Command} =~ /^list-contexts$/i) {
    print Dumper({Date => $args{Date}});
    # in the future we will want to call this in some microtheorymt
    my $res = $store->ListContexts
		  (
		   Date => $args{Date},
		  );
    print Dumper($res);
    return {
	    Result => $res,
	   };
  } elsif ($args{Command} =~ /^rename-context$/i) {
    print Dumper({Date => $args{Date}});
    my $res = $store->RenameContext
      (
       Context => $context,
       NewContext => $args{Data}->{NewContext},
      );
    return {
	    Result => $res,
	   };
  } elsif ($args{Command} =~ /^clear-context$/i) {
    print Dumper({Date => $args{Date}});
    my $res = $store->ClearContext
      (
       Context => $context,
      );
    return {
	    Result => $res,
	   };
  } elsif ($args{Command} =~ /^remove-context$/i) {
    print Dumper({Date => $args{Date}});
    my $res = $store->RemoveContext
      (
       Context => $context,
      );
    return {
	    Result => $res,
	   };
  } elsif ($args{Command} =~ /^restart-reasoner$/i) {
    my $res = $store->RestartReasoner();
    return {
	    Result => $res,
	   };
  }
}

1;
