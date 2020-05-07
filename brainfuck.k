// >	inc pointer
// <	dec pointer
// +	inc the byte at pointer.
// -	dec the byte at pointer.
// .	output the byte at pointer.
// ,	accept one byte of input, store in the byte at pointer
// [	if the byte at pointer is zero, jump pointer past matching ]
// ]	if the byte at pointer is nonzero, jump pointer back to matching [

// TODO:
// - charToInt, intToChar
// - test with other backends
// Implementation settings:
// - Memory Size (default 30,000)
// - cell size
// - memory overflow behavior (wrap, halt, etc.)
// - memory starting values
module BRAINFUCK-SYNTAX
  imports DOMAINS-SYNTAX

  syntax Cmd ::= "+"
              | "-"
              | ">"
              | "<"
              | ","
              | "."

  syntax While ::= "[" "]"
                | "[" Exp "]"

  syntax Exp ::= Cmd
               | While
               | Exp Exp [left, strict]

endmodule

// TODO:
// - this shits slow as hell. damn - Is it parsing, execution, or both?
  // - my guess is that this is parsing related rather than execution, partially because the parsing approach seems highly non-standard. It's possible that it also has to do with our memory expansion approach. next step may be to directly pass in the ast for an equivalently large program and see if we can isolate execution speed.
  // - indeed, only parsing 256 +'s seems to be taking outrageously long'
  // - after removing all execution and basically all of the parsing, still got OutOfMemoryError. It would appear that 200 or so commands is just a lot to parse. This seems wrong though. Surely we can parse a 200 line program?
  // - 300+ operations via loops shows no noticeable increase in resources usage or time
module BRAINFUCK
  imports DOMAINS
  imports BRAINFUCK-SYNTAX

  syntax KResult ::= Op
  syntax Op ::= "INCVAL"
              | "DECVAL"
              | "INCPTR"
              | "DECPTR"
              | "READ"
              | "PRINT"
              | "LOOP" Exp

  configuration
    <bf>
      <k>      $PGM:Exp    </k>
      <ptr>    0:Int       </ptr>
      <mem>    .Map        </mem>
      <input>  .List       </input>
      <output> .List       </output>
    </bf>

  rule E1:Exp E2:Exp => E1 ~> E2 [structural]
  rule +        => INCVAL     [structural]
  rule -        => DECVAL     [structural]
  rule >        => INCPTR     [structural]
  rule <        => DECPTR     [structural]
  rule ,        => READ       [structural]
  rule .:Cmd    => PRINT      [structural]
  rule [ ]      => LOOP .     [structural]
  rule [ BODY ] => LOOP BODY  [structural]

  rule
    <k> INCVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (M => inc( M )) ...</mem>
  rule
    <k> INCVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> 1) </mem>
  requires notBool (PTR in keys(RHO))

  rule
    <k> DECVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (M => dec( M )) ...</mem>
  rule
    <k> DECVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> chop( -1 ))</mem>
  requires notBool (PTR in keys(RHO))

  rule
    <k> INCPTR => .K ...</k>
    <ptr> PTR => PTR +Int 1 </ptr>
  requires PTR <Int 30000
  rule
    <k> DECPTR => .K ...</k>
    <ptr> PTR => PTR -Int 1 </ptr>
  requires PTR >=Int 1

  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (_ => IN) ...</mem>
    <input> ListItem(IN) => .List ...</input>
  rule
    <k> READ => .K ...</k>
    <mem>... PTR |-> (_ => 0) ...</mem>
    <input> .List </input>
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> IN) </mem>
    <input> ListItem(IN) => .List ...</input>
  requires notBool (PTR in keys(RHO))
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> 0) </mem>
    <input> .List </input>
  requires notBool (PTR in keys(RHO))

  rule
    <k> PRINT => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> M ...</mem>
    <output>... .List => ListItem(M) </output>
  rule
    <k> PRINT => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map </mem>
    <output>... .List => ListItem(0) </output>
  requires notBool (PTR in keys(RHO))

  rule
    <k> LOOP OPS => OPS ~> LOOP OPS ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> M ...</mem>
  requires M >Int 0
  rule
    <k> LOOP OPS => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> M ...</mem>
  requires M ==Int 0
  rule
    <k> LOOP OPS => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO </mem>
  requires notBool (PTR in keys(RHO))

  syntax Int ::= inc ( Int )  [function, functional]
  rule inc( I ) => chop( I +Int 1 )
  syntax Int ::= dec ( Int )  [function, functional]
  rule dec( I ) => chop( I -Int 1 )

  syntax Int ::= "pow8"
  rule pow8 => 256 [macro]

  syntax Int ::= chop ( Int )  [function, functional]
  rule chop( I ) => I requires I >=Int 0 andBool I <Int pow8
  rule chop( I ) => I %Int pow8 requires I >=Int pow8
  rule chop( I ) => chop( pow8 +Int I ) requires I <Int 0

// optimizations to zero a cell
  /* rule */
  /*   <k> LOOP - => .K ...</k> */
  /*   <ptr> PTR </ptr> */
  /*   <mem>... PTR |-> (_ => 0) ...</mem> */
  /* rule */
  /*   <k> LOOP + => .K ...</k> */
  /*   <ptr> PTR </ptr> */
  /*   <mem>... PTR |-> (_ => 0) ...</mem> */

endmodule
