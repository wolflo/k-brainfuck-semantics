// >	inc pointer
// <	dec pointer
// +	inc the byte at pointer.
// -	dec the byte at pointer.
// .	output the byte at pointer.
// ,	accept one byte of input, store in the byte at pointer
// [	if the byte at pointer is zero, jump pointer past matching ]
// ]	if the byte at pointer is nonzero, jump pointer back to matching [

module BRAINFUCK-SYNTAX
  imports DOMAINS-SYNTAX

  syntax Op ::= ">"
              | "<"
              | "["
              | "]"
              | "+"
              | "-"
              | ","
              | "dot"

  syntax Exp ::= Op
               | Exp Exp [left]

endmodule

module BRAINFUCK
  imports DOMAINS
  imports BRAINFUCK-SYNTAX

// TODO:
// - jumps
// - 8 bit cells
// - halts?
// - better representation of memory?
// - abstract pc incrementing
  configuration <T>
                  <k>      $PGM:Exp </k>
                  <pc>     0:Int    </pc>
                  <ptr>    0:Int    </ptr>
                  <mem>    .Map     </mem>
                  <input>  ListItem(17) ListItem(13) </input>
                  <output> .List    </output>
                </T>

  rule E1:Exp E2:Exp => E1 ~> E2 [structural]

  // TODO: has to be a better way to do all this read matching
  rule
    <k> , => .K ...</k>
    <pc> PC => PC +Int 1 </pc>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (_ => IN) ...</mem>
    <input> ListItem(IN) INS => INS </input>
  // TODO: write zero at end of input?
  rule
    <k> , => .K ...</k>
    <pc> PC => PC +Int 1 </pc>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (_ => 0) ...</mem>
    <input> .List </input>
  rule
    <k> , => .K ...</k>
    <pc> PC => PC +Int 1 </pc>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR|->IN) </mem>
    <input> ListItem(IN) INS => INS </input>
  requires notBool (PTR in keys(RHO))
  rule
    <k> , => .K ...</k>
    <pc> PC => PC +Int 1 </pc>
    <ptr> PTR </ptr>
    <mem> RHO:Map (.Map => PTR|->0) </mem>
    <input> .List </input>
  requires notBool (PTR in keys(RHO))



// TODO figure out how to use . in syntax
  // write output
  rule
    <k> dot => .K ...</k>
    <pc> PC => PC +Int 1 </pc>
    <ptr> PTR </ptr>
    <mem>... PTR |-> OUT ...</mem>
    <output> OUTS => OUTS ListItem(OUT) </output>
  rule
    <k> dot => .K ...</k>
    <pc> PC => PC +Int 1 </pc>
    <ptr> PTR </ptr>
    <mem>... PTR |-> OUT ...</mem>
    <output> .List => ListItem(OUT) </output>


  // move pointer
  rule
    <k> > => .K ...</k>
    <pc> PC => PC +Int 1 </pc>
    <ptr> PTR => PTR +Int 1 </ptr>
  rule
    <k> < => .K ...</k>
    <pc> PC => PC +Int 1 </pc>
    <ptr> PTR => PTR -Int 1 </ptr>
  requires PTR >=Int 1

  // TODO: do these match in all cases we want them to?
  rule
    <k> + => .K ...</k>
    <pc> PC => PC +Int 1 </pc>
    <ptr> PTR </ptr>
    <mem> Rho:Map (.Map => PTR|->1) </mem>
  requires notBool (PTR in keys(Rho))
  rule
    <k> + => .K ...</k>
    <pc> PC => PC +Int 1 </pc>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (V => V +Int 1) ...</mem>
  rule
    <k> - => .K ...</k>
    <pc> PC => PC +Int 1 </pc>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (V => V -Int 1) ...</mem>
  requires V >=Int 1

  // shortcuts
  rule
    <k> [ ~> - ~>  ] => .K ...</k>
    <pc> PC => PC +Int 3 </pc>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (V => 0) ...</mem>
  rule
    <k> [ ~> + ~>  ] => .K ...</k>
    <pc> PC => PC +Int 3 </pc>
    <ptr> PTR </ptr>
    <mem>... PTR |-> (V => 0) ...</mem>

endmodule
