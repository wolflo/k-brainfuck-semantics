// >	inc pointer
// <	dec pointer
// +	inc the byte at pointer.
// -	dec the byte at pointer.
// .	output the byte at pointer.
// ,	accept one byte of input, store in the byte at pointer
// [	if the byte at pointer is zero, jump pointer past matching ]
// ]	if the byte at pointer is nonzero, jump pointer back to matching [ +1

module BRAINFUCK-SYNTAX
  imports DOMAINS-SYNTAX

  syntax Op ::= ">"
              | "<"
              | "["
              | "]"
              | "+"
              | "-"
              | ","
              | "."

  syntax Exp ::= Op
               | Exp Exp [left]

endmodule

module BRAINFUCK
  imports DOMAINS
  imports BRAINFUCK-SYNTAX

  configuration <T>
                  <k> $PGM:Exp </k>
                  <ptr> 0:Int </ptr>
                  <mem> .Map </mem>
                </T>

  rule E1:Exp E2:Exp => E1 ~> E2 [structural]

  rule
    <k> > => .K ...</k>
    <ptr> P => P +Int 1 </ptr>
  rule
    <k> < => .K ...</k>
    <ptr> P => P -Int 1 </ptr>
  requires P >=Int 1

  // TODO: do these match in all cases we want them to?
  rule
    <k> + => .K ...</k>
    <ptr> P </ptr>
    <mem> Rho:Map (.Map => P|->1) </mem>
  requires notBool (P in keys(Rho))
  rule
    <k> + => .K ...</k>
    <ptr> P </ptr>
    <mem>... P |-> (V => V +Int 1) ...</mem>
  rule
    <k> - => .K ...</k>
    <ptr> P </ptr>
    <mem>... P |-> (V => V -Int 1) ...</mem>
  requires V >=Int 1

endmodule
