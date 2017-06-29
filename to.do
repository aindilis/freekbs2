(Update FreeKBS2 to have a partial or total order over all the assertions, for use with Prolog and Cyc and other order based logical languages.  We need to experiment to see if we could speed UniLang up somehow.  Could use a linked list or tree or whatever, with a tsort. Could combine this with a more efficient mechanism if possible for FreeKBS2, such as several arity tables for the different relations, and implement that, and then have our persistence.) 
(
 FreeKBS2 uses Vampire, but an open source version of it based on KIF that's available as part of the Sigma KEE environment.  The version in that Systems.tgz file is Vampire-3.0 (which I've attached), which is very powerful (for instance I believe you don't have to reload the entire theory into the prover every query, maybe multicore support, etc).  I think FreeKBS2 should have interfaces to as many provers as possible (eventually), but for now we will want at least 1 free and open source prover, which I recommend to be 'E'.  However, if we get all the others for free if we get that one, then that is good.  One capability that Vampire-KIF has is to provide bindings for variables, so you can query values that way.  I'm not sure which other provers have this, however, it is highly desirable.  It did take me some time to write the interface for Vampire-KIF bindings, so I'm not sure.  A lot of refactoring may be needed.  However, all of this is still not absolutely necessary, because we do have inferencing with Vampire.

 Another discovery I made yesterday was the research into Large Theory Problems, of the kind that we'll be dealing with.  the LTP stuff is all First Order, like Vampire, but there is a system I believe MaLARea or something that does well that we now have.  Not sure what the license is there.

 The last topic is higher order theorem proving.  I got a response on that letter I sent to the author of LEO-II, he was supportive.  I'll forward it to you.

 The real question for all of this I see is how to integrate FreeKBS2 or FreeKBS3 with what is already out there (such as the different syntaxes for logic that are used such as in TPTP).  I plan to make modifications to KBS2::ImportExport to add new syntaxes and parsers.  I can already add a KIF2THF conversion (THF being the higher order logic syntax used in the competition (in addition to LEO-II for HOL there is another prover which is very winning and GPL Satallax-MaLeS 1.2))

 http://www.cs.miami.edu/~tptp/CASC/24/WWWFiles/DivisionSummary1.html
 http://www.cs.ru.nl/~kuehlwein/
 https://code.google.com/p/males/
 )

(Optimize the following
 (
  and f1.ID=m.FormulaID
  and f2.ParentFormulaID=f1.ID
  and m.ContextID=48

  explain select f1.ID from metadata m, formulae f1, formulae f2, arguments a1, arguments a2, arguments a3, arguments a4, arguments a5 where a1.ParentFormulaID=f1.ID and a1.Value='has-thumbnail' and a2.ParentFormulaID=f2.ID and a2.Value='document-fn' and a3.ParentFormulaID=f2.ID and a3.Value='paperport' and a4.ParentFormulaID=f2.ID and a4.Value='P0EqpCwCwU' and a5.ParentFormulaID=f1.ID and a5.Value='thumbnail.gif' and f1.ID=m.FormulaID and f2.ParentFormulaID=f1.ID and m.ContextID=48	;

  explain select f1.ID from metadata m, formulae f1, formulae f2, arguments a1, arguments a2, arguments a3, arguments a4, arguments a5 where f1.ID=m.FormulaID and f2.ParentFormulaID=f1.ID and m.ContextID=48 and  a1.ParentFormulaID=f1.ID and a1.Value='has-thumbnail' and a2.ParentFormulaID=f2.ID and a2.Value='document-fn' and a3.ParentFormulaID=f2.ID and a3.Value='paperport' and a4.ParentFormulaID=f2.ID and a4.Value='P0EqpCwCwU' and a5.ParentFormulaID=f1.ID and a5.Value='thumbnail.gif' ;

select f1.ID from metadata m, formulae f1, arguments a1, arguments a2, arguments a3 where a1.ParentFormulaID=f1.ID and a1.Value='isa' and a2.ParentFormulaID=f1.ID and a2.Value='x' and a3.ParentFormulaID=f1.ID and a3.Value='y' and f1.ID=m.FormulaID and m.ContextID=2

select f1.ID from metadata m, formulae f1, formulae f2, arguments a1, arguments a2, arguments a3, arguments a4, arguments a5 where a1.ParentFormulaID=f1.ID and a1.Value='has-thumbnail' and a2.ParentFormulaID=f2.ID and a2.Value='document-fn' and a3.ParentFormulaID=f2.ID and a3.Value='paperport' and a4.ParentFormulaID=f2.ID and a4.Value='8alz7uQiJB' and a5.ParentFormulaID=f1.ID and a5.Value='thumbnail.gif' and f1.ID=m.FormulaID and f2.ParentFormulaID=f1.ID and m.ContextID=48

select f1.ID from metadata m, formulae f1, formulae f2, arguments a1, arguments a2, arguments a3, arguments a4, arguments a5 where a1.ParentFormulaID=f1.ID and a1.Value='has-folder' and a2.ParentFormulaID=f2.ID and a2.Value='document-fn' and a3.ParentFormulaID=f2.ID and a3.Value='paperport' and a4.ParentFormulaID=f2.ID and a4.Value='U9H3lWmTPv' and a5.ParentFormulaID=f1.ID and a5.Value='Incoming' and f1.ID=m.FormulaID and f2.ParentFormulaID=f1.ID and m.ContextID=48

  )

 )


(implementing unassert
 (create a different test database so as to not cause corruption to our usual one)
 (also backup our usual one anyway - ensure that backups are going on)
 ()
 )




(add the ability to import kif files, and cycl files, and rdfs
 and owl, etc)

(solution
 (have to figure out why it isn't answering all answers when given
  the chess problem or similar)
 (need to set <query>(this is my query)</query> to <query bindingsLimit='100'> or so)
 )

(make an ontology of sorts of the different engines and their
 results and what they mean.  in other words vampire cannot or
 possibly could be bent into proving satisfaction, but for what
 logics?  map this all out, so that whenever we have a given set
 of assertions, and need a particular function (entails,
						satisfies, valid-p, consistent-p, etc, it knows what to do, also
						spec out performances, use as input to Learner or Perform, etc))


(ensure the operation of the Formalize2 freekbs-execute perl option)

(consolidate all KBS2::ImportExport instances)

(consider auto context classification of items)

(need to fix the thing with Vampire having a syntax error when
 constants start with a number and then have non numbers)

(here are some things)

(find the logic form to logic converter and add it to importexport)

(add wsd agents, integrate results of function calls)

(For reasoning, we can have an "assert without checking
 consistency" to speed things up.)

(Here are some issues
 ;; (can't assert anything into an empty theory, as the query or whatever fails)
 (need to instantiate the translation of arbitrary freekbs terms into KIF)
 (need to finish the unasserting abilities, by finding matching formula)
 ;; (need to optimize the database)
 (need to fix the uncertainty)
 (need to fix the problem on Vampire's end with proofs dropping
  closing parentheses) 
 )

(KBs to load
 OpenCyc
 SUMO
 # WordNet
 # ConceptNet
 # CycSynsetMappings
 All Known Ontologies
 TPTP (use this for practice and calibration)
 Any texts we want to process, with Formalize
 ExtendedWordNet
 )

(possible improvements
 (replace raw formula format with an object)
 (replace glob variables with an object)
 (get rid of all mentions of relation)
 ))
