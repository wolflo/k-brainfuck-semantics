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
    andBool inc M <Int #intSize ENV
  rule
    <k> (. => #halt WORD_OVERFLOW) ~> INCVAL ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> M ...</mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool (notBool inc M <Int #intSize ENV)


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
    andBool dec M >=Int 0
  rule
    <k> (.K => #halt WORD_OVERFLOW) ~> DECVAL ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> M ...</mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool (notBool dec M >=Int 0)
  rule
    <k> (.K => #halt WORD_OVERFLOW) ~> DECVAL ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map </mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool (notBool (PTR in keys(RHO)))


  /// >
  rule
    <k> INCPTR => .K ...</k>
    <ptr> PTR => #winc PTR ENV </ptr>
    <env> ENV </env>
  requires WrapMemory < ENV >

  rule
    <k> INCPTR => .K ...</k>
    <ptr> PTR => inc PTR </ptr>
    <env> ENV </env>
  requires notBool WrapMemory < ENV >
    andBool inc PTR <Int MemorySize < ENV >

  rule
    <k> (.K => #halt MEMORY_OVERFLOW) ~> INCPTR ...</k>
    <ptr> PTR </ptr>
    <env> ENV </env>
  requires notBool WrapMemory < ENV >
    andBool inc PTR >=Int MemorySize < ENV >


  /// <
  rule
    <k> DECPTR => .K ...</k>
    <ptr> PTR => #wdec PTR ENV </ptr>
    <env> ENV </env>
  requires WrapMemory < ENV >

  rule
    <k> DECPTR => .K ...</k>
    <ptr> PTR => dec PTR </ptr>
  requires notBool WrapMemory < ENV >
    andBool dec PTR >=Int 0

  rule
    <k> (.K => #halt MEMORY_OVERFLOW) ~> DECPTR ...</k>
    <ptr> PTR => dec PTR </ptr>
  requires notBool WrapMemory < ENV >
    andBool dec PTR <Int 0


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

// read
// - eof action
// - is eof
// - uninitialized mem cell
// - is within wordsize

  /// ,
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (_ => ordHead IN ) ...</mem>
    <env> ENV </env>
    <input> ListItem(IN:String) => .List ...</input>
  requires 0 <= ordHead IN < #intSize ENV
  // uinitialized read
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> ordHead IN ) </mem>
    <env> ENV </env>
    <input> ListItem(IN) => .List ...</input>
  requires notBool (PTR in keys(RHO))
    andBool 0 <= ordHead IN < #intSize ENV

  // EOF read - write 0
  rule
    <k> READ => .K ...</k>
    <mem>... PTR |-> (_ => 0) ...</mem>
    <env> ENV </env>
    <input> .List </input>
  requires notBool (EOFNoOp < ENV >)
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> 0) </mem>
    <env> ENV </env>
    <input> .List </input>
  requires notBool (EOFNoOp < ENV >)
    andBool (notBool (PTR in keys(RHO)))
  // EOF Read - no op
  rule
    <k> READ => .K ...</k>
    <env> ENV </env>
    <input> .List </input>
  requires EOFNoOp < ENV >

  // read - overflow
  rule
    <k> (. => #halt WORD_OVERFLOW) ~> READ ...</k>
    <env> ENV </env>
    <input> ListItem(IN:String) ...</input>
  requires notBool 0 <= ordHead IN < #intSize ENV


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
