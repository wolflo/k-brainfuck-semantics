requires "syntax.k"
requires "types.k"
requires "data.k"

// TODO:
// - ignore non-C-style comments
// - haskell backend error
module BRAINFUCK
  imports DOMAINS
  imports BRAINFUCK-SYNTAX
  imports BRAINFUCK-DATA
  imports BRAINFUCK-TYPES

  configuration
    <bf>
      <k>     $PGM:Exp </k>
      <ptr>   0:Int    </ptr>
      <mem>   .Map     </mem>
      <env>   DEFAULT  </env>
      <input> .List    </input>
      <output> .List </output>
    </bf>

  rule E1:Exp E2:Exp => E1 ~> E2      [structural]

  rule +        => INCVAL             [structural]
  rule -        => DECVAL             [structural]
  rule >        => INCPTR             [structural]
  rule <        => DECPTR             [structural]
  rule ,        => READ               [structural]
  rule .:Cmd    => PRINT              [structural]
  rule [ ]      => LOOP .             [structural]
  rule [ BODY ] => LOOP BODY          [structural]

  syntax KItem ::= "#halt" ErrorCode
  rule <k> #halt ERROR ~> (_:Exp => .K) ...</k>
  rule <k> #halt ERROR ~> (_:Op => .K) ...</k>

  /// +
  // increment an uninitialized memory cell
  rule
    <k> INCVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> 1) </mem>
  requires notBool (PTR in_keys(RHO))
  // wrapping increment
  rule
    <k> INCVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (M => chop (inc M) (#intSize ENV)) ...</mem>
    <env> ENV </env>
  requires WrapWords < ENV >
  // non-wrapping increment
  rule
    <k> INCVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (M => inc M) ...</mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool inc M <Int #intSize ENV
  rule
    <k> (.K => #halt WORD_OVERFLOW) ~> INCVAL ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> M ...</mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool inc M >=Int #intSize ENV


  /// -
  // wrapping decrement
  rule
    <k> DECVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (M => chop (dec M) (#intSize ENV)) ...</mem>
    <env> ENV </env>
  requires WrapWords < ENV >
  rule
    <k> DECVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> chop -1 (#intSize ENV)) </mem>
    <env> ENV </env>
  requires WrapWords < ENV >
    andBool (notBool (PTR in_keys(RHO)))

  // non-wrapping decrement
  rule
    <k> DECVAL => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (M => dec M) ...</mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool M >=Int 1
  rule
    <k> (.K => #halt WORD_OVERFLOW) ~> DECVAL ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> M ...</mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool M <Int 1
  rule
    <k> (.K => #halt WORD_OVERFLOW) ~> DECVAL ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map </mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool (notBool (PTR in_keys(RHO)))


  /// >
  rule
    <k> INCPTR => .K ...</k>
    <ptr> PTR => chop (inc PTR) (#memSize ENV) </ptr>
    <env> ENV </env>
  requires WrapMemory < ENV >

  rule
    <k> INCPTR => .K ...</k>
    <ptr> PTR => inc PTR </ptr>
    <env> ENV </env>
  requires notBool WrapMemory < ENV >
    andBool inc PTR <Int #memSize ENV

  rule
    <k> (.K => #halt MEMORY_OVERFLOW) ~> INCPTR ...</k>
    <ptr> PTR </ptr>
    <env> ENV </env>
  requires notBool WrapMemory < ENV >
    andBool inc PTR >=Int #memSize ENV


  /// <
  rule
    <k> DECPTR => .K ...</k>
    <ptr> PTR => chop (dec PTR) (#memSize ENV) </ptr>
    <env> ENV </env>
  requires WrapMemory < ENV >

  rule
    <k> DECPTR => .K ...</k>
    <ptr> PTR => dec PTR </ptr>
    <env> ENV </env>
  requires notBool WrapMemory < ENV >
    andBool dec PTR >=Int 0

  rule
    <k> (.K => #halt MEMORY_OVERFLOW) ~> DECPTR ...</k>
    <ptr> PTR => dec PTR </ptr>
    <env> ENV </env>
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
    <mem> RHO:Map </mem>
  requires notBool (PTR in_keys(RHO))

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
  requires notBool (PTR in_keys(RHO))
    andBool 0 <= ordHead IN < #intSize ENV

  // EOF read - write EOFValue to cell
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (_ => chop (#eofVal ENV) (#intSize ENV)) ...</mem>
    <env> ENV </env>
    <input> .List </input>
  requires notBool (EOFNoOp < ENV >)
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> chop (#eofVal ENV) (#intSize ENV)) </mem>
    <env> ENV </env>
    <input> .List </input>
  requires notBool (EOFNoOp < ENV >)
    andBool (notBool (PTR in_keys(RHO)))
  // EOF Read - no op
  rule
    <k> READ => .K ...</k>
    <env> ENV </env>
    <input> .List </input>
  requires EOFNoOp < ENV >

  // read - overflow
  rule
    <k> (.K => #halt WORD_OVERFLOW) ~> READ ...</k>
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
  requires notBool (PTR in_keys(RHO))

endmodule
