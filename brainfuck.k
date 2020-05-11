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

////
  syntax Env ::= "NOWRAP"
  rule X:EnvInt  < NOWRAP > => X < DEFAULT > 
  rule X:EnvBool < NOWRAP > => X < DEFAULT > 
    requires notBool X ==K WrapWords
  rule WrapWords < NOWRAP > => false
////

  configuration
    <bf>
      <k>     $PGM:Exp </k>
      <ptr>   0:Int    </ptr>
      <mem>   .Map     </mem>
      <env>   NOWRAP  </env>
      <input> .List    </input>
      <output stream="stdout"> .List </output>
    </bf>


  rule E:Exp => #exp2Op E             [structural]
  rule E1:Exp E2:Exp => E1 ~> E2      [structural]

  syntax ErrorCode ::= ".ErrorCode"
                     | "EOF"
                     | "WORD_OVERFLOW"
                     | "MEMORY_OVERFLOW"
  syntax KItem ::= "#halt" ErrorCode
  rule <k> #halt ERROR ~> (_:Exp => .K) ...</k>
  rule <k> #halt ERROR ~> (_:Op => .K) ...</k>

  /// +
  // increment an uninitialized memory cell
  rule
    <k> INCVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> 1) </mem>
  requires notBool (PTR in keys(RHO))
  // wrapping increment
  rule
    <k> INCVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (M => #winc M ENV ) ...</mem>
    <env> ENV </env>
  requires WrapWords < ENV >
  // non-wrapping increment
  rule
    <k> INCVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (M => inc M ) ...</mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool 0 <= inc M < #intSize ENV
  rule
    <k> INCVAL => #halt WORD_OVERFLOW ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> M ...</mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool (notBool 0 <= inc M < #intSize ENV)

  /// -
  // wrapping decrement
  rule
    <k> DECVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (M => #wdec M ENV) ...</mem>
    <env> ENV </env>
  requires WrapWords < ENV >
  rule
    <k> DECVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> chop -1 (#intSize ENV) ) </mem>
    <env> ENV </env>
  requires WrapWords < ENV >
    andBool (notBool (PTR in keys(RHO)))

  // non-wrapping derement
  rule
    <k> DECVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (M => dec M) ...</mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool 0 <= dec M < #intSize ENV
  rule
    <k> DECVAL => #halt WORD_OVERFLOW ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> M ...</mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool (notBool 0 <= dec M < #intSize ENV)
  rule
    <k> DECVAL => #halt WORD_OVERFLOW ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map </mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool (notBool (PTR in keys(RHO)))

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
  // TODO: require value be within wordsize
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
