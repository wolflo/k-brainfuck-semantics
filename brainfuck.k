// >	inc pointer
// <	dec pointer
// +	inc the byte at pointer.
// -	dec the byte at pointer.
// .	output the byte at pointer.
// ,	accept one byte of input, store in the byte at pointer
// [	if the byte at pointer is zero, jump pointer past matching ]
// ]	if the byte at pointer is nonzero, jump pointer back to matching [

// TODO:
// - ignore non-C-style comments
// - test with other backends
// - stdin? Might be a lost Kause
// Implementation settings:
// - Memory Size (default 30,000)
// - cell size
// - memory overflow behavior (wrap, halt, etc.)
// - memory starting values
// - endiannes?
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
               // strict kompiled with haskell backend fails to cool anything
               /* | Exp Exp [left, strict] */
               | Exp Exp [left]

endmodule

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
      <output stream="stdout"> .List </output>
      /* <exit-code exit=""> 0 </exit-code> */
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
    <mem>... PTR |-> (_ => #ordHead( IN )) ...</mem>
    <input> ListItem(IN:String) => .List ...</input>
  rule
    <k> READ => .K ...</k>
    <mem>... PTR |-> (_ => 0) ...</mem>
    <input> .List </input>
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> #ordHead( IN )) </mem>
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
    <output>... .List => ListItem(chrChar(M))</output>
  rule
    <k> PRINT => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map </mem>
    <output>... .List => ListItem(chrChar(0))</output>  //TODO
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

  syntax Int ::= #ordHead( String ) [function]
  rule #ordHead( S ) => ordChar(substrString(S, 0, 1)) requires lengthString(S) >=Int 1
  rule #ordHead( S ) => 0 requires lengthString(S) ==Int 0

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
