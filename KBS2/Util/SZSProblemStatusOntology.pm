package KBS2::Util::SZSProblemStatusOntology;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / PreciseOutputForms CanAssert TruthValue Hierarchy StatusOntology /

  ];

sub init {
  my ($self,%args) = @_;
  # F: Ax => C
  # F (marked with star)

  # not sure exactly what this means
  $self->PreciseOutputForms
    ({
      "Assurance" => "Ass",
      "Refutation" => "Ref",
      "CNFRefutation" => "CRf",
      "Proof" => "Prf",
      "Model" => "Mod",
      "Saturation" => "Sat",
      "None" => "Non",
     });

  # can assert refers to whether, in a given theory, we can assert
  # something based on the result of the check of it's relation to the
  # existing KB
  $self->CanAssert
    ({
      "_Already Asserted" => {
			     CanAssert => 0,
			    },
      "_Negation Already Asserted" => {
			     CanAssert => 0,
			    },
      "Tautology" => {
		      CanAssert => 1,
		     },
      "TautologousConclusion" => {
				  CanAssert => 1,
				 },
      "Equivalent" => {
		       CanAssert => 1,
		      },
      "Theorem" => {
		    CanAssert => 1,
		   },
      "Satisfiable" => {
			CanAssert => 1,
		       },
      "ContradictoryAxioms" => { # should we allow to assert if the axioms are inconsistent anyway?
				CanAssert => undef,
			       },
      "NoConsequence" => {
			  CanAssert => 1,
			 },
      "CounterSatisfiable" => { # unsure what to do here, because it seems to still allow satisfiable
			       CanAssert => undef,
			      },
      "CounterTheorem" => {
			   CanAssert => 0,
			  },
      "CounterEquivalent" => {
			      CanAssert => 0,
			     },
      "Unsatisfiable" => {
			  CanAssert => 0,
			 },
      "Unsatisfiable" => {
			  CanAssert => 0,
			 },
      #       "SatisfiabilityBijection" => 0,
      #       "SatisfiabilityMapping" => 0,
      #       "SatisfiabilityPartialMapping" => 0,
      #       "SatisfiabilityPreserving" => 0,
      #       "CounterSatisfiabilityPreserving" => 0,
      #       "CounterSatisfiabilityPartialMapping" => 0,
      #       "CounterSatisfiabilityMapping" => 0,
      #       "CounterSatisfiabilityBijection" => 0,
      #       # unsolved statuses
      #       "Inappropriate" => undef,	# well, this reasoner can't answer this question
      #       "Unknown" => 0,
      #       "InputError" => undef,	# the system should inform the query agent that there is an error in the input
      #       "GaveUp" => 0,
      #       "ResourceOut" => 0,
      #       "Assumed" => 0,
     });

  # a system for figuring out if things are true or not
  $self->TruthValue
    ({
      "_Already Asserted" => {
			      TruthValue => "true",
			    },
      "Tautology" => {
		      TruthValue => "true",
		     },
      "TautologousConclusion" => {
				  TruthValue => "true",
				 },
      "Equivalent" => {
		       TruthValue => "true",
		      },
      "Theorem" => {
		    TruthValue => "true",
		   },
      "Satisfiable" => {
			TruthValue => "independent",
		       },
      "ContradictoryAxioms" => { # should we allow to assert if the axioms are inconsistent anyway?
				Reasons => {
					    "input broken" => 1,
					   },
				Success => 0,
			       },
      "NoConsequence" => {
			  TruthValue => "independent",
			 },
      "CounterSatisfiable" => { # unsure what to do here, because it seems to still allow satisfiable
			       TruthValue => "unknown",
			      },
      "CounterTheorem" => {
			   TruthValue => "false",
			  },
      "CounterEquivalent" => {
			      TruthValue => "false",
			     },
      "Unsatisfiable" => {
			  TruthValue => "false",
			 },
      "Unsatisfiable" => {
			  TruthValue => "false",
			 },
      #       "SatisfiabilityBijection" => 0,
      #       "SatisfiabilityMapping" => 0,
      #       "SatisfiabilityPartialMapping" => 0,
      #       "SatisfiabilityPreserving" => 0,
      #       "CounterSatisfiabilityPreserving" => 0,
      #       "CounterSatisfiabilityPartialMapping" => 0,
      #       "CounterSatisfiabilityMapping" => 0,
      #       "CounterSatisfiabilityBijection" => 0,
      #       # unsolved statuses
      "Inappropriate" => {
			  TruthValue => "unknown",	# well, this reasoner can't answer this question
			 },
      "Unknown" => {
		    TruthValue => "unknown",,
		   },
      "InputError" => {
		       Reasons => {
				   "input broken" => 1,
				  },
		       Success => 0,
		      },
      "GaveUp" => {
		   TruthValue => "unknown",
		  },
      "ResourceOut" => {
			TruthValue => "unknown",
		       },
      "Assumed" => {
		    TruthValue => "assumed",
		   },
     });

  # an hierarchy of all statuses
  $self->Hierarchy
    ({
      "System Status" => {
			  "Solved Status" => {
					      "Deductive Status" => 1,
					      "Preserving Status" => 1,
					     },
			  "Unsolved Status" => {
						"{Unsolved Ontology} \ | /" => {
										"Open" => 1,
									       },
					       },
			 },
      "Deductive Status" => {
			     "Satisfiable*" => {
						"Theorem" => {
							      "Tautologous Conclusion" => {
											   "(1) Tautology*" => 1,
											  },
							      "Equivalent" => {
									       "(1) Tautology*" => 1,
									      },
							     },
					       },
			     "Counter Satisfiable*" => {
							"Counter Theorem" => {
									      "Counter Equivalent" => {
												       "(2) Unsatisfiable*" => 1,
												      },
									      "Unsatisfiable Conclusion" => {
													     "(2) Unsatisfiable*" => 1,
													    },
									     },
						       },
			     "& No Consquence" => {
						   "& Contradictory Axioms" => 1,
						  },
			    },
      "Preserving Status" => {
			      "Satisfiability Preserving" => {
							      "Satisfiability Partial Mapping" => {
												   "Satisfiability Mapping" => {
																"Satisfiability Bijection" => 1,
															       },
												  },
							     },
			      "Counter Satisfiability Preserving" => {
								      "Counter Satisfiability Partial Mapping" => {
														   "Counter Satisfiability Mapping" => {
																			"Counter Satisfiability Bijection" => 1,
																		       },
														  },
								     },
			     },
      "Unsolved Status" => {
			    "Unknown" => {
					  "Inappropriate" => 1,
					  "InputError" => {
							   "GaveUp(Reason)" => 1,
							  },
					 },
			    "GaveUp" => 1,
			    "ResourceOut" => {
					      "Timeout" => 1,
					      "ResourceOut(What)" => 1,
					     },
			    "Assumed(UnsolvedStatus,SolvedStatus)" => 1,
			   },
     });

  # a description of all possible system statuses
  $self->StatusOntology
    ({
      "Deductive Statuses" => {
			       "Tautology" => {
					       Abbreviation => "TAU",
					       Description => "Every interpretation is a model of Ax and a model of C",
					       Shows => {
							 "F is valid" => 1,
							 "~F is unsatisfiable" => 1,
							 "C is a tautology" => 1,
							},
					       "Expected output" => [
								     "Assurance",
								     "Proof of F",
								     "Refutation of ~F",
								    ],
					      },
			       "TautologousConclusion" => {
							   Abbreviation => "TAC",
							   Description => "Every interpretation is a model of C",
							   Shows => {
								     "F is valid" => 1,
								     "C is a tautology" => 1,
								    },
							   "Expected output" => [
										 "Assurance",
										 "Proof of C",
										 "Refutation of ~C",
										],
							  },
			       "Equivalent" => {
						Abbreviation => "EQV",
						Description => "Ax and C have the same models (and there are some)",
						Shows => {
							  "F is valid" => 1,
							  "C is a theorem of Ax" => 1,
							 },
						"Expected output" => [
								      "Assurance",
								      "Proof of C from Ax and proof of Ax from C",
								      "Refutation of Ax U {~C} and refutation of ~Ax U {C}",
								      "Refutation of CNF(Ax U {~C}) and refutation of CNF(~Ax U {C})",
								     ],
					       },
			       "Theorem" => {
					     Abbreviation => "THM",
					     Description => "Every model of Ax (and there are some) is a model of C",
					     Shows => {
						       "F is valid" => 1,
						       "C is a theorem of Ax" => 1,
						      },
					     "Expected output" => [
								   "Assurance",
								   "Proof of C from Ax",
								   "Refutation of Ax U {~C}",
								   "Refutation of CNF(Ax U {~C})",
								  ],
					    },
			       "Satisfiable" => {
						 Abbreviation => "SAT",
						 Description => "Some models of Ax (and there are some) are models of C",
						 Shows => {
							   "F is satisfiable" => 1,
							   "~F is not valid" => 1,
							   "C is not a theorem of Ax" => 1,
							  },
						 "Expected output" => [
								       "Assurance",
								       "Model of Ax and C",
								       "Saturation",
								      ],
						},
			       "ContradictoryAxioms" => {
							 Abbreviation => "CAX",
							 Description => "There are no models of Ax",
							 Shows => {
								   "F is valid" => 1,
								   "Anything is a theorem of Ax" => 1,
								  },
							 "Expected output" => [
									       "Assurance",
									       "Refutation of Ax",
									       "Refutation of CNF(Ax)",
									      ],
							},
			       "NoConsequence" => {
						   Abbreviation => "NOC",
						   Description => "Some models of Ax (and there are some) are models of C, and some are models of ~C.",
						   Shows => {
							     "F is not valid" => 1,
							     "F is satisfiable" => 1,
							     "~F is not valid" => 1,
							     "~F is satisfiable" => 1,
							     "C is not a theorem of Ax" => 1,
							    },
						   "Expected output" => [
									 "Assurance",
									 "Pair of models, one of Ax and C, and one of Ax and ~C",
									 "Pair of saturations",
									],
						  },
			       "CounterSatisfiable" => {
							Abbreviation => "CSA",
							Description => "Some models of Ax (and there are some) are models of ~C",
							Shows => {
								  "F is not valid" => 1,
								  "~F is satisfiable" => 1,
								  "C is not a theorem of Ax" => 1,
								 },
							"Expected output" => [
									      "Assurance",
									      "Model Ax and ~C",
									      "Saturation",
									     ],
						       },
			       "CounterTheorem" => {
						    Abbreviation => "CTH",
						    Description => "Every model of Ax (and there are some) is a model of ~C",
						    Shows => {
							      "F is invalid" => 1,
							      "~F is valid" => 1,
							      "~C is a theorem of Ax" => 1,
							      "C cannot be made into a theorem of Ax by extending Ax" => 1,
							     },
						    "Expected output" => [
									  "Assurance",
									  "Proof of ~C from Ax",
									  "Refutation of Ax U {C}",
									  "Refutation of CNF(Ax U {C})",
									 ],
						   },
			       "CounterEquivalent" => {
						       Abbreviation => "CEQ",
						       Description => "Ax and ~C have the same models (and there are some)",
						       Shows => {
								 "F is not valid" => 1,
								 "~C is a theorem of Ax" => 1,
								 "Every interpretation is a model of Ax xor a model of C" => 1,
								},
						       "Expected output" => [
									     "Assurance",
									     "Proof of ~C from Ax and proof of Ax from ~C",
									     "Refutation of Ax U {C} and refutation of ~Ax U {~C}",
									     "Refutation of CNF(Ax U {C}) and refutation of CNF(~Ax U {~C})",
									    ],
						      },
			       "Unsatisfiable" => {
						   Abbreviation => "onclusion (UNC",
						   Description => "Every interpretation is a model of ~C",
						   Shows => {
							     "~C is a tautology" => 1,
							    },
						   "Expected output" => [
									 "Assurance",
									 "Proof of ~C",
									 "Refutation of C",
									],
						  },
			       "Unsatisfiable" => {
						   Abbreviation => "UNS",
						   Description => "Every interpretation is a model of Ax and a model of ~C",
						   Shows => {
							     "F is unsatisfiable" => 1,
							     "~F is valid" => 1,
							     "~C is a tautology" => 1,
							    },
						   "Expected output" => [
									 "Assurance",
									 "Refutation of F",
									 "Proof of ~F",
									],
						  },
			      },

      "Preserving Statuses" => {

				"SatisfiabilityBijection" => {
							      Abbreviation => "SAB",
							      Description => "There is a bijection between the models of Ax (and there are some) and models of C",
							      Example => "Skolemization, psuedo-splitting",
							      Shows => {
									"F is satisfiable" => 1,
								       },
							      "Expected output" => [
										    "Assurance",
										   ],
							     },
				"SatisfiabilityMapping" => {
							    Abbreviation => "SAM",
							    Description => "There is a mapping from the models of Ax (and there are some) to models of C",
							    Shows => {
								      "F is satisfiable" => 1,
								     },
							    "Expected output" => [
										  "Assurance",
										 ],
							   },
				"SatisfiabilityPartialMapping" => {
								   Abbreviation => "SAR",
								   Description => "There is a partial mapping from the models of Ax (and there are some) to models of C",
								   Example => "Ax = {p | q}, C = p & r",
								   Shows => {
									     "Nothing about F" => 1,
									    },
								   "Expected output" => [
											 "Assurance",
											 "Pairs of models",
											 "Pairs of saturations",
											],
								  },
				"SatisfiabilityPreserving" => {
							       Abbreviation => "SAP",
							       Description => "If there exists a model of Ax then there exists a model of C",
							       Shows => {
									 "F is satisfiable" => 1,
									},
							       "Expected output" => [
										     "Assurance",
										    ],
							      },
				"CounterSatisfiabilityPreserving" => {
								      Abbreviation => "CSP",
								      Description => "If there exists a model of Ax then there exists a model of ~C",
								      Shows => {
										"Nothing about F" => 1,
									       },
								      "Expected output" => [
											    "Assurance",
											   ],
								     },
				"CounterSatisfiabilityPartialMapping" => {
									  Abbreviation => "CSR",
									  Description => "There is a partial mapping from the models of Ax (and there are some) to models of ~C",
									  Shows => {
										    "Nothing about F" => 1,
										   },
									  "Expected output" => [
												"Assurance",
												"Pairs of models",
											       ],
									 },
				"CounterSatisfiabilityMapping" => {
								   Abbreviation => "CSM",
								   Description => "There is a mapping from the models of Ax (and there are some) to models of ~C",
								   Shows => {
									     "Nothing about F" => 1,
									    },
								   "Expected output" => [
											 "Assurance",
											],
								  },
				"CounterSatisfiabilityBijection" => {
								     Abbreviation => "CSB",
								     Description => "There is a bijection between the models of Ax (and there are some) and models of ~C",
								     Shows => {
									       "Nothing about F" => 1,
									      },
								     "Expected output" => [
											   "Assurance",
											  ],
								    },
			       },
      "Unsolved Statuses" => {

			      "Inappropriate" => {
						  Abbreviation => "IAP",
						  Description => "The system cannot attempt this type of problem, in principle",
						 },
			      "Unknown" => {
					    Abbreviation => "UNK",
					    Description => "System exited before the time limit for unknown reason",
					   },
			      "InputError" => {
					       Description => "System exited due to an error in its input",
					      },
			      "GaveUp" => {
					   Abbreviation => "GUP",
					   Description => "System gave up before the time limit",
					   Return => {
						      Reason => "And this is the reason",
						     },
					  },
			      "ResourceOut" => {
						Description => "System exited due to running out of some non-time resource",
						Children => {
							     "Timeout" => {
									   Abbreviation => "TMO",
									   Description => "System ran past user imposed CPU time limit",
									  },
							     "What" => {
									Return => "Resource that system ran out of",
								       },
							    },
					       },
			      "Assumed" => {
					    Description => "System assumes that the problem has the status",
					    Children => {
							 "UnsolvedStatus" => {
									      Return => {
											 BLANK => "Why the problem was unsolved and hence an assumption made",
											},
									     },
							 "SolvedStatus" => {
									    Return => {
										       BLANK => "The assumed status",
										      },
									   },
							},
					   },

			     }
     });
}

1;
