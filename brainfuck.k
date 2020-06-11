requires "syntax.k"
requires "types.k"
requires "data.k"

module BRAINFUCK
  imports DOMAINS
  imports BRAINFUCK-SYNTAX
  imports BRAINFUCK-DATA
  imports BRAINFUCK-TYPES

  configuration
    <bf>
      <k>      $PGM:Exp </k>
      <ptr>    0:Int    </ptr>
      <mem>    .Map     </mem>
      <env>    DEFAULT  </env>
      <input>  .List    </input>
      <output> .List    </output>
    </bf>

  // sequence expressions
  rule E1:Exp E2:Exp => E1 ~> E2      [macro]

  // brainfuck commands to internal op representation
  rule +        => INCVAL             [macro]
  rule -        => DECVAL             [macro]
  rule >        => INCPTR             [macro]
  rule <        => DECPTR             [macro]
  rule ,        => READ               [macro]
  rule .:Cmd    => PRINT              [macro]
  rule [ ]      => LOOP .             [macro]
  rule [ BODY ] => LOOP BODY          [macro]

  // halt takes an error code and consumes remaining operations
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

  // halt on overflow if non-wrapping
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

  // wrapping decrement, uninitialized memory cell
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

  // halt on underflow if non-wrapping
  rule
    <k> (.K => #halt WORD_OVERFLOW) ~> DECVAL ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> M ...</mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool M <Int 1

  // halt on decrement of uninitialized memory cell if non-wrapping
  rule
    <k> (.K => #halt WORD_OVERFLOW) ~> DECVAL ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map </mem>
    <env> ENV </env>
  requires notBool WrapWords < ENV >
    andBool (notBool (PTR in_keys(RHO)))


  /// >
  // wrapping pointer increment
  rule
    <k> INCPTR => .K ...</k>
    <ptr> PTR => chop (inc PTR) (#memSize ENV) </ptr>
    <env> ENV </env>
  requires WrapMemory < ENV >

  // non-wrapping pointer increment
  rule
    <k> INCPTR => .K ...</k>
    <ptr> PTR => inc PTR </ptr>
    <env> ENV </env>
  requires notBool WrapMemory < ENV >
    andBool inc PTR <Int #memSize ENV

  // halt on memory overflow if non-wrapping
  rule
    <k> (.K => #halt MEMORY_OVERFLOW) ~> INCPTR ...</k>
    <ptr> PTR </ptr>
    <env> ENV </env>
  requires notBool WrapMemory < ENV >
    andBool inc PTR >=Int #memSize ENV


  /// <
  // wrapping pointer decrement
  rule
    <k> DECPTR => .K ...</k>
    <ptr> PTR => chop (dec PTR) (#memSize ENV) </ptr>
    <env> ENV </env>
  requires WrapMemory < ENV >

  // non-wrapping pointer decrement
  rule
    <k> DECPTR => .K ...</k>
    <ptr> PTR => dec PTR </ptr>
    <env> ENV </env>
  requires notBool WrapMemory < ENV >
    andBool dec PTR >=Int 0

  // halt on memory underflow if non-wrapping
  rule
    <k> (.K => #halt MEMORY_OVERFLOW) ~> DECPTR ...</k>
    <ptr> PTR => dec PTR </ptr>
    <env> ENV </env>
  requires notBool WrapMemory < ENV >
    andBool dec PTR <Int 0


  /// [ ... ]
  // enter loop
  rule
    <k> LOOP OPS => OPS ~> LOOP OPS ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> M ...</mem>
  requires M >Int 0

  // continue
  rule
    <k> LOOP OPS => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> M ...</mem>
  requires M ==Int 0

  // continue if uninitialized memory cell (uninitialized is zero)
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
  // read
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (_ => ordHead IN ) ...</mem>
    <env> ENV </env>
    <input> ListItem(IN:String) => .List ...</input>
  requires 0 <= ordHead IN < #intSize ENV

  // read to an uninitialized memory cell
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> ordHead IN ) </mem>
    <env> ENV </env>
    <input> ListItem(IN) => .List ...</input>
  requires notBool (PTR in_keys(RHO))
    andBool 0 <= ordHead IN < #intSize ENV

  // read from empty input - write EOFValue to cell
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (_ => chop (#eofVal ENV) (#intSize ENV)) ...</mem>
    <env> ENV </env>
    <input> .List </input>
  requires notBool (EOFNoOp < ENV >)

  // read from empty input - write EOFValue to uninitialized memory cell
  rule
    <k> READ => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR |-> chop (#eofVal ENV) (#intSize ENV)) </mem>
    <env> ENV </env>
    <input> .List </input>
  requires notBool (EOFNoOp < ENV >)
    andBool (notBool (PTR in_keys(RHO)))

  // read from empty input - EOF no-op
  rule
    <k> READ => .K ...</k>
    <env> ENV </env>
    <input> .List </input>
  requires EOFNoOp < ENV >

  // read a value larger than the wordsize
  rule
    <k> (.K => #halt WORD_OVERFLOW) ~> READ ...</k>
    <env> ENV </env>
    <input> ListItem(IN:String) ...</input>
  requires notBool 0 <= ordHead IN < #intSize ENV


  /// .
  // print
  rule
    <k> PRINT => .K ...</k>
    <ptr> PTR </ptr>
    <mem>... PTR |-> M ...</mem>
    <output>... .List => ListItem(chrChar(M)) </output>

  // print an uninitialized memory cell
  rule
    <k> PRINT => .K ...</k>
    <ptr> PTR </ptr>
    <mem> RHO:Map </mem>
    <output>... .List => ListItem(chrChar(0)) </output>  //TODO
  requires notBool (PTR in_keys(RHO))

endmodule
