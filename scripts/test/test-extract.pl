#!/usr/bin/perl -w

use PerlLib::Util;
use UniLang::Util::Message;

use Data::Dumper;

my $VAR1 = bless( {
                 'Contents' => '',
                 'ID' => '0',
                 'Receiver' => 'KBS2-client-0.657198042230554',
                 'Data' => {
                             'Result' => {
                                           'Type' => 'Theorem',
                                           'Attributes' => {
                                                             'LoadSize' => 3,
                                                             'Models' => 1
                                                           },
                                           'Output' => {
                                                         'Assurance' => 'None given at this time',
                                                         'Proof of C from Ax' => '<proof>
  <proofStep>
    <premises/>
    <conclusion>
      <formula number="9">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="9">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
    </premises>
    <conclusion>
      <formula number="13">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="13">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
    </premises>
    <conclusion>
      <formula number="17">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="17">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
    </premises>
    <conclusion>
      <formula number="21">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="21">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
    </premises>
    <conclusion>
      <clause number="25">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <clause number="25">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
    </premises>
    <conclusion>
      <clause number="26">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <clause number="26">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
    </premises>
    <conclusion>
      <clause number="31">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises/>
    <conclusion>
      <formula number="6">
             (temp g h i)
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="6">
             (temp g h i)
          </formula>
    </premises>
    <conclusion>
      <formula number="10">
             (temp g h i)
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="10">
             (temp g h i)
          </formula>
    </premises>
    <conclusion>
      <formula number="14">
             (temp g h i)
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="14">
             (temp g h i)
          </formula>
    </premises>
    <conclusion>
      <formula number="18">
             (temp g h i)
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="18">
             (temp g h i)
          </formula>
    </premises>
    <conclusion>
      <clause number="22">
            (temp g h i)
          </clause>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <clause number="22">
            (temp g h i)
          </clause>
    </premises>
    <conclusion>
      <clause number="29">
            (temp g h i)
          </clause>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <clause number="29">
            (temp g h i)
          </clause>
    </premises>
    <conclusion>
      <clause number="34">
            (temp g h i)
          </clause>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <clause number="31">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
      <clause number="34">
            (temp g h i)
          </clause>
    </premises>
    <conclusion>
      <clause number="38">
            ($answer i h g)
          </clause>
    </conclusion>
  </proofStep>
</proof>',
                                                         'Refutation of Ax U {~C}' => 'None given at this time',
                                                         'Refutation of CNF(Ax U {~C})' => 'None given at this time'
                                                       },
                                           'Results' => [
                                                          {
                                                            'Query' => '<assertion>(temp g h i)</assertion>',
                                                            'Response' => '<assertionResponse>
  Formula has been added to the session database
</assertionResponse>'
                                                          },
                                                          {
                                                            'Query' => '<assertion>(temp d e f)</assertion>',
                                                            'Response' => '<assertionResponse>
  Formula has been added to the session database
</assertionResponse>'
                                                          },
                                                          {
                                                            'Query' => '<assertion>(temp a b c)</assertion>',
                                                            'Response' => '<assertionResponse>
  Formula has been added to the session database
</assertionResponse>'
                                                          },
                                                          {
                                                            'Query' => '<query>(temp ?X ?Y ?Z)</query>',
                                                            'Result' => {
                                                                          'Type' => 'Theorem',
                                                                          'Attributes' => {
                                                                                            'LoadSize' => 3,
                                                                                            'Models' => 1
                                                                                          },
                                                                          'Output' => {
                                                                                        'Assurance' => 'None given at this time',
                                                                                        'Proof of C from Ax' => '<proof>
  <proofStep>
    <premises/>
    <conclusion>
      <formula number="9">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="9">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
    </premises>
    <conclusion>
      <formula number="13">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="13">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
    </premises>
    <conclusion>
      <formula number="17">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="17">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
    </premises>
    <conclusion>
      <formula number="21">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="21">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
    </premises>
    <conclusion>
      <clause number="25">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <clause number="25">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
    </premises>
    <conclusion>
      <clause number="26">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <clause number="26">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
    </premises>
    <conclusion>
      <clause number="31">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises/>
    <conclusion>
      <formula number="6">
             (temp g h i)
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="6">
             (temp g h i)
          </formula>
    </premises>
    <conclusion>
      <formula number="10">
             (temp g h i)
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="10">
             (temp g h i)
          </formula>
    </premises>
    <conclusion>
      <formula number="14">
             (temp g h i)
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="14">
             (temp g h i)
          </formula>
    </premises>
    <conclusion>
      <formula number="18">
             (temp g h i)
          </formula>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <formula number="18">
             (temp g h i)
          </formula>
    </premises>
    <conclusion>
      <clause number="22">
            (temp g h i)
          </clause>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <clause number="22">
            (temp g h i)
          </clause>
    </premises>
    <conclusion>
      <clause number="29">
            (temp g h i)
          </clause>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <clause number="29">
            (temp g h i)
          </clause>
    </premises>
    <conclusion>
      <clause number="34">
            (temp g h i)
          </clause>
    </conclusion>
  </proofStep>
  <proofStep>
    <premises>
      <clause number="31">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
      <clause number="34">
            (temp g h i)
          </clause>
    </premises>
    <conclusion>
      <clause number="38">
            ($answer i h g)
          </clause>
    </conclusion>
  </proofStep>
</proof>',
                                                                                        'Refutation of Ax U {~C}' => 'None given at this time',
                                                                                        'Refutation of CNF(Ax U {~C})' => 'None given at this time'
                                                                                      }
                                                                        },
                                                            'Response' => '<queryResponse>
  <answer result="yes" number="1">
    <bindingSet type="definite">
      <binding>
        <var name="?Z" value="c"/>
        <var name="?Y" value="b"/>
        <var name="?X" value="a"/>
      </binding>
    </bindingSet>
    <proof>
      <proofStep>
        <premises/>
        <conclusion>
          <formula number="9">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="9">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
        </premises>
        <conclusion>
          <formula number="13">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="13">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
        </premises>
        <conclusion>
          <formula number="17">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="17">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
        </premises>
        <conclusion>
          <formula number="21">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="21">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
        </premises>
        <conclusion>
          <clause number="25">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="25">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </premises>
        <conclusion>
          <clause number="26">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="26">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </premises>
        <conclusion>
          <clause number="31">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises/>
        <conclusion>
          <formula number="8">
             (temp a b c)
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="8">
             (temp a b c)
          </formula>
        </premises>
        <conclusion>
          <formula number="12">
             (temp a b c)
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="12">
             (temp a b c)
          </formula>
        </premises>
        <conclusion>
          <formula number="16">
             (temp a b c)
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="16">
             (temp a b c)
          </formula>
        </premises>
        <conclusion>
          <formula number="20">
             (temp a b c)
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="20">
             (temp a b c)
          </formula>
        </premises>
        <conclusion>
          <clause number="24">
            (temp a b c)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="24">
            (temp a b c)
          </clause>
        </premises>
        <conclusion>
          <clause number="27">
            (temp a b c)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="27">
            (temp a b c)
          </clause>
        </premises>
        <conclusion>
          <clause number="32">
            (temp a b c)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="31">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
          <clause number="32">
            (temp a b c)
          </clause>
        </premises>
        <conclusion>
          <clause number="36">
            ($answer c b a)
          </clause>
        </conclusion>
      </proofStep>
    </proof>
  </answer>
  <answer result="yes" number="2">
    <bindingSet type="definite">
      <binding>
        <var name="?Z" value="f"/>
        <var name="?Y" value="e"/>
        <var name="?X" value="d"/>
      </binding>
    </bindingSet>
    <proof>
      <proofStep>
        <premises/>
        <conclusion>
          <formula number="9">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="9">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
        </premises>
        <conclusion>
          <formula number="13">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="13">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
        </premises>
        <conclusion>
          <formula number="17">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="17">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
        </premises>
        <conclusion>
          <formula number="21">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="21">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
        </premises>
        <conclusion>
          <clause number="25">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="25">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </premises>
        <conclusion>
          <clause number="26">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="26">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </premises>
        <conclusion>
          <clause number="31">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises/>
        <conclusion>
          <formula number="7">
             (temp d e f)
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="7">
             (temp d e f)
          </formula>
        </premises>
        <conclusion>
          <formula number="11">
             (temp d e f)
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="11">
             (temp d e f)
          </formula>
        </premises>
        <conclusion>
          <formula number="15">
             (temp d e f)
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="15">
             (temp d e f)
          </formula>
        </premises>
        <conclusion>
          <formula number="19">
             (temp d e f)
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="19">
             (temp d e f)
          </formula>
        </premises>
        <conclusion>
          <clause number="23">
            (temp d e f)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="23">
            (temp d e f)
          </clause>
        </premises>
        <conclusion>
          <clause number="28">
            (temp d e f)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="28">
            (temp d e f)
          </clause>
        </premises>
        <conclusion>
          <clause number="33">
            (temp d e f)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="31">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
          <clause number="33">
            (temp d e f)
          </clause>
        </premises>
        <conclusion>
          <clause number="37">
            ($answer f e d)
          </clause>
        </conclusion>
      </proofStep>
    </proof>
  </answer>
  <answer result="yes" number="3">
    <bindingSet type="definite">
      <binding>
        <var name="?Z" value="i"/>
        <var name="?Y" value="h"/>
        <var name="?X" value="g"/>
      </binding>
    </bindingSet>
    <proof>
      <proofStep>
        <premises/>
        <conclusion>
          <formula number="9">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="9">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
        </premises>
        <conclusion>
          <formula number="13">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="13">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
        </premises>
        <conclusion>
          <formula number="17">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="17">
             (forall (?X2 ?X1 ?X0)
               (not (temp ?X0 ?X1 ?X2)))
          </formula>
        </premises>
        <conclusion>
          <formula number="21">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="21">
             (not (temp ?X0 ?X1 ?X2))
          </formula>
        </premises>
        <conclusion>
          <clause number="25">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="25">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </premises>
        <conclusion>
          <clause number="26">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="26">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </premises>
        <conclusion>
          <clause number="31">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises/>
        <conclusion>
          <formula number="6">
             (temp g h i)
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="6">
             (temp g h i)
          </formula>
        </premises>
        <conclusion>
          <formula number="10">
             (temp g h i)
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="10">
             (temp g h i)
          </formula>
        </premises>
        <conclusion>
          <formula number="14">
             (temp g h i)
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="14">
             (temp g h i)
          </formula>
        </premises>
        <conclusion>
          <formula number="18">
             (temp g h i)
          </formula>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <formula number="18">
             (temp g h i)
          </formula>
        </premises>
        <conclusion>
          <clause number="22">
            (temp g h i)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="22">
            (temp g h i)
          </clause>
        </premises>
        <conclusion>
          <clause number="29">
            (temp g h i)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="29">
            (temp g h i)
          </clause>
        </premises>
        <conclusion>
          <clause number="34">
            (temp g h i)
          </clause>
        </conclusion>
      </proofStep>
      <proofStep>
        <premises>
          <clause number="31">
            (not (temp ?X0 ?X1 ?X2))
            ($answer ?X2 ?X1 ?X0)
          </clause>
          <clause number="34">
            (temp g h i)
          </clause>
        </premises>
        <conclusion>
          <clause number="38">
            ($answer i h g)
          </clause>
        </conclusion>
      </proofStep>
    </proof>
  </answer>
  <summary proofs="3"/>
</queryResponse>',
                                                            'Models' => [
                                                                          {
                                                                            'BindingSet' => [
                                                                                              {
                                                                                                '?X' => 'a',
                                                                                                '?Y' => 'b',
                                                                                                '?Z' => 'c'
                                                                                              }
                                                                                            ],
                                                                            'Type' => 'definite',
                                                                            'Formulae' => [
                                                                                            [
                                                                                              'temp',
                                                                                              'a',
                                                                                              'b',
                                                                                              'c'
                                                                                            ]
                                                                                          ]
                                                                          },
                                                                          {
                                                                            'BindingSet' => [
                                                                                              {
                                                                                                '?X' => 'd',
                                                                                                '?Y' => 'e',
                                                                                                '?Z' => 'f'
                                                                                              }
                                                                                            ],
                                                                            'Type' => 'definite',
                                                                            'Formulae' => [
                                                                                            [
                                                                                              'temp',
                                                                                              'd',
                                                                                              'e',
                                                                                              'f'
                                                                                            ]
                                                                                          ]
                                                                          },
                                                                          {
                                                                            'BindingSet' => [
                                                                                              {
                                                                                                '?X' => 'g',
                                                                                                '?Y' => 'h',
                                                                                                '?Z' => 'i'
                                                                                              }
                                                                                            ],
                                                                            'Type' => 'definite',
                                                                            'Formulae' => [
                                                                                            [
                                                                                              'temp',
                                                                                              'g',
                                                                                              'h',
                                                                                              'i'
                                                                                            ]
                                                                                          ]
                                                                          }
                                                                        ]
                                                          }
                                                        ],
                                           'Bindings' => [
                                                           [
                                                             [
                                                               [
                                                                 \*{'::?X'},
                                                                 'a'
                                                               ],
                                                               [
                                                                 \*{'::?Y'},
                                                                 'b'
                                                               ],
                                                               [
                                                                 \*{'::?Z'},
                                                                 'c'
                                                               ]
                                                             ],
                                                             [
                                                               [
                                                                 $VAR1->{'Data'}{'Result'}{'Bindings'}[0][0][0][0],
                                                                 'd'
                                                               ],
                                                               [
                                                                 $VAR1->{'Data'}{'Result'}{'Bindings'}[0][0][1][0],
                                                                 'e'
                                                               ],
                                                               [
                                                                 $VAR1->{'Data'}{'Result'}{'Bindings'}[0][0][2][0],
                                                                 'f'
                                                               ]
                                                             ],
                                                             [
                                                               [
                                                                 $VAR1->{'Data'}{'Result'}{'Bindings'}[0][0][0][0],
                                                                 'g'
                                                               ],
                                                               [
                                                                 $VAR1->{'Data'}{'Result'}{'Bindings'}[0][0][1][0],
                                                                 'h'
                                                               ],
                                                               [
                                                                 $VAR1->{'Data'}{'Result'}{'Bindings'}[0][0][2][0],
                                                                 'i'
                                                               ]
                                                             ]
                                                           ]
                                                         ]
                                         },
                             '_DoNotLog' => 1,
                             '_TransactionSequence' => 1,
                             '_TransactionID' => '0.925887012093707'
                           },
                 'Date' => 'Sat Mar 27 22:28:44 CDT 2010',
                 'Sender' => 'KBS2'
               }, 'UniLang::Util::Message' );


sub DumperStructure {
  my (%args) = @_;
  my $item = $args{Item};
  my $ref = ref $item;
  if ($ref eq "ARRAY") {
    my $array = [];
    foreach my $subitem (@$item) {
      push @$array, DumperStructure
	(
	 Item => $subitem,
	);
    }
    return $array;
  } elsif ($ref eq "HASH" or $ref eq "UniLang::Util::Message") {
    my $hash = {};
    foreach my $key (keys %$item) {
      $hash->{$key} = DumperStructure
	(
	 Item => $item->{$key},
	);
    }
    return $hash;
  } elsif ($ref eq "") {
    return "";
  }
}

print Dumper(DumperStructure(Item => $VAR1));
