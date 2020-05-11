requires "data.k"
requires "syntax.k"
// TODO:
// - how to make unset env parameters default to DEFAULT?
// - ignore non-C-style comments - see python semantics?
// - haskell backend error
// - halts
module BRAINFUCK
  imports DOMAINS
  imports BRAINFUCK-SYNTAX
  imports BRAINFUCK-DATA

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
      <k>     $PGM:Exp </k>
      <ptr>   0:Int    </ptr>
      <mem>   .Map     </mem>
      <env>   DEFAULT  </env>
      <input> .List    </input>
      <output stream="stdout"> .List </output>
    </bf>

  rule E:Exp => #exp2Op E             [structural]
  rule E1:Exp E2:Exp => E1 ~> E2      [structural]

  syntax ErrorCode ::= ".ErrorCode"
  syntax KItem ::= "#halt" ErrorCode
  rule <k> #halt ERROR ~> (_ => .K) ... </k>

  /// +
  rule
    <k> INCVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (M => inc ENV M ) ...</mem>
    <env> ENV </env>
  rule
    <k> INCVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> 1) </mem>
  requires notBool (PTR in keys(RHO))

  /// -
  rule
    <k> DECVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (M => dec ENV M ) ...</mem>
    <env> ENV </env>
  rule
    <k> DECVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> chop -1 (#intSize ENV) ) </mem>
    <env> ENV </env>
  requires notBool (PTR in keys(RHO))

  /// >
  rule
    <k> INCPTR => .K ...</k>
    <ptr> PTR => PTR +Int 1 </ptr>
    <env> ENV </env>
  requires (notBool WrapMemory < ENV >) andBool PTR <Int (MemorySize < ENV >)

  /// <
  rule
    <k> DECPTR => .K ...</k>
    <ptr> PTR => PTR -Int 1 </ptr>
  requires PTR >=Int 1

  /// ,
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (_ => ordHead IN ) ...</mem>
    <input> ListItem(IN:String) => .List ...</input>
  rule
    <k> READ => .K ...</k>
    <mem>... PTR |-> (_ => 0) ...</mem>
    <input> .List </input>
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> ordHead IN ) </mem>
    <input> ListItem(IN) => .List ...</input>
  requires notBool (PTR in keys(RHO))
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> 0) </mem>
    <input> .List </input>
  requires notBool (PTR in keys(RHO))

  /// .
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

  /// [ ... ]
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

  syntax Op ::= "#exp2Op" Exp       [function]
  rule #exp2Op +        => INCVAL
  rule #exp2Op -        => DECVAL
  rule #exp2Op >        => INCPTR
  rule #exp2Op <        => DECPTR
  rule #exp2Op ,        => READ
  rule #exp2Op .:Cmd    => PRINT
  rule #exp2Op [ ]      => LOOP .
  rule #exp2Op [ BODY ] => LOOP BODY

endmodule
