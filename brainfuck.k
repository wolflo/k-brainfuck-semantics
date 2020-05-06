// >	inc pointer
// <	dec pointer
// +	inc the byte at pointer.
// -	dec the byte at pointer.
// .	output the byte at pointer.
// ,	accept one byte of input, store in the byte at pointer
// [	if the byte at pointer is zero, jump pointer past matching ]
// ]	if the byte at pointer is nonzero, jump pointer back to matching [
requires "types.k"

module BRAINFUCK-SYNTAX
  imports DOMAINS-SYNTAX

  syntax Cmd ::= ">"
              | "<"
              | "["
              | "]"
              | "+"
              | "-"
              | ","
              | "."
  syntax Exp ::= Cmd
               | Exp Exp [left]

endmodule

/* // TODO: */
/* // - jumps */
/* // - 8 bit cells */
/* // - halts? */
/* // - better representation of memory? */
/* // - abstract pc incrementing */
module BRAINFUCK
  imports DOMAINS
  imports BRAINFUCK-SYNTAX
  imports TYPES

  syntax Op ::= "INCPTR"
              | "DECPTR"
              | "INCVAL"
              | "DECVAL"
              | "INPUT"
              | "OUTPUT"
              | "JUMP" Int  // td: do we need 2 different jumps?

  syntax Ops = Lst
  syntax Ops ::= ".Ops"
  syntax Lstable ::= Op
  rule .Ops => .Lst [macro]

  configuration <bf>
                  <k>      $PGM:K   </k>
                  <pgm>    .Ops     </pgm>
                  <pc>     0        </pc>
                  <ptr>    0        </ptr>
                  <mem>    .List    </mem>
                  <input>  .List    </input>
                  <output> .List    </output>
                </bf>

  // TODO: how to handle jump translation?
  // convert cmds to ops and place in pgm cell
  rule
    <k> C:Cmd => .K ...</k>
    <pgm> OS:Ops => OS ++ (#cmdToOp( C ) :: .Ops) </pgm>
  [structural]

  rule E1:Exp E2:Exp => E1 ~> E2 [structural]

  syntax Op ::= #cmdToOp ( Cmd ) [function]
  rule #cmdToOp( + ) => INCVAL
  rule #cmdToOp( - ) => DECVAL
  rule #cmdToOp( > ) => INCPTR
  rule #cmdToOp( < ) => DECPTR

// when the k-cell is empty, we load the next op based on the PC, unless PC > size(pgm_array), in which case we're done



/*   // TODO: has to be a better way to do all this read matching */
/*   rule */
/*     <k> , => .K ...</k> */
/*     <pc> PC => PC +Int 1 </pc> */
/*     <ptr> PTR </ptr> */
/*     <mem>... PTR |-> (_ => IN) ...</mem> */
/*     <input> ListItem(IN) INS => INS </input> */
/*   // TODO: write zero at end of input? */
/*   rule */
/*     <k> , => .K ...</k> */
/*     <pc> PC => PC +Int 1 </pc> */
/*     <ptr> PTR </ptr> */
/*     <mem>... PTR |-> (_ => 0) ...</mem> */
/*     <input> .List </input> */
/*   rule */
/*     <k> , => .K ...</k> */
/*     <pc> PC => PC +Int 1 </pc> */
/*     <ptr> PTR </ptr> */
/*     <mem> RHO:Map (.Map => PTR|->IN) </mem> */
/*     <input> ListItem(IN) INS => INS </input> */
/*   requires notBool (PTR in keys(RHO)) */
/*   rule */
/*     <k> , => .K ...</k> */
/*     <pc> PC => PC +Int 1 </pc> */
/*     <ptr> PTR </ptr> */
/*     <mem> RHO:Map (.Map => PTR|->0) </mem> */
/*     <input> .List </input> */
/*   requires notBool (PTR in keys(RHO)) */



/* // TODO figure out how to use . in syntax */
/*   // write output */
/*   rule */
/*     <k> OUTPUT => .K ...</k> */
/*     <pc> PC => PC +Int 1 </pc> */
/*     <ptr> PTR </ptr> */
/*     <mem>... PTR |-> OUT ...</mem> */
/*     <output> OUTS => OUTS ListItem(OUT) </output> */
/*   rule */
/*     <k> OUTPUT => .K ...</k> */
/*     <pc> PC => PC +Int 1 </pc> */
/*     <ptr> PTR </ptr> */
/*     <mem>... PTR |-> OUT ...</mem> */
/*     <output> .List => ListItem(OUT) </output> */

/*   // move pointer */
/*   rule */
/*     <k> > => .K ...</k> */
/*     <pc> PC => PC +Int 1 </pc> */
/*     <ptr> PTR => PTR +Int 1 </ptr> */
/*   rule */
/*     <k> < => .K ...</k> */
/*     <pc> PC => PC +Int 1 </pc> */
/*     <ptr> PTR => PTR -Int 1 </ptr> */
/*   requires PTR >=Int 1 */

/*   // TODO: do these match in all cases we want them to? */
/*   rule */
/*     <k> + => .K ...</k> */
/*     <pc> PC => PC +Int 1 </pc> */
/*     <ptr> PTR </ptr> */
/*     <mem> Rho:Map (.Map => PTR|->1) </mem> */
/*   requires notBool (PTR in keys(Rho)) */
/*   rule */
/*     <k> + => .K ...</k> */
/*     <pc> PC => PC +Int 1 </pc> */
/*     <ptr> PTR </ptr> */
/*     <mem>... PTR |-> (V => V +Int 1) ...</mem> */
/*   rule */
/*     <k> - => .K ...</k> */
/*     <pc> PC => PC +Int 1 </pc> */
/*     <ptr> PTR </ptr> */
/*     <mem>... PTR |-> (V => V -Int 1) ...</mem> */
/*   requires V >=Int 1 */

/*   // shortcuts */
/*   rule */
/*     <k> [ ~> - ~>  ] => .K ...</k> */
/*     <pc> PC => PC +Int 3 </pc> */
/*     <ptr> PTR </ptr> */
/*     <mem>... PTR |-> (V => 0) ...</mem> */
/*   rule */
/*     <k> [ ~> + ~>  ] => .K ...</k> */
/*     <pc> PC => PC +Int 3 </pc> */
/*     <ptr> PTR </ptr> */
/*     <mem>... PTR |-> (V => 0) ...</mem> */

endmodule
