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

// TODO:
// - jumps
// - 8 bit cells
// - halts?
// - better representation of memory?
// - abstract pc incrementing
// - we should always inc memory when ptr goes past size(mem)
// - this shits slow as hell. damn - Is it parsing, execution, or both?
module BRAINFUCK
  imports DOMAINS
  imports BRAINFUCK-SYNTAX

  syntax Op ::= "INCVAL"
              | "DECVAL"
              | "READ"
              | "PRINT"
              | "INCPTR"
              | "DECPTR"
              | "JUMP" Int  // td: do we need 2 different jumps?

  configuration <bf>
                  <k>      $PGM:Exp     </k>
                  <pc>     0            </pc>
                  <ptr>    0            </ptr>
                  <pgm>    .List        </pgm>
                  <mem>    ListItem(0)  </mem>
                  <input>  .List        </input>
                  <output> .List        </output>
                </bf>

  // sequence commands
  rule E1:Exp E2:Exp => E1 ~> E2 [structural]

  // TODO: how to handle jump translation?
  // convert cmds to ops and place in pgm cell
  rule <k> C:Cmd => .K ...</k>
       <pgm>... .List => ListItem(#cmdToOp( C )) </pgm>
    [structural]

//TODO: java backend gets stuck on first loaded op
  // TODO: add a termination case
  // load the next op based on the PC
  rule <k> .K => PGM[ PC ]</k>
       <pc> PC => PC +Int 1 </pc>
       <pgm> PGM </pgm>
    requires notBool PC >=Int size(PGM)

  // TODO: overflow
  rule <k> INCVAL => .K ...</k>
       <ptr> PTR </ptr>
       <mem> MEM => #incElem( MEM , PTR ) </mem>  // mem[ptr]++
  rule <k> DECVAL => .K ...</k>
       <ptr> PTR </ptr>
       <mem> MEM => #decElem( MEM , PTR ) </mem>  // mem[ptr]--

  rule <k> INCPTR => .K ...</k>
       <ptr> PTR => PTR +Int 1 </ptr>
       <mem> MEM => #growList(MEM, PTR +Int 1, 0) </mem>

  rule <k> DECPTR => .K ...</k>
       <ptr> PTR => PTR -Int 1 </ptr>
    requires PTR >=Int 1

  syntax Op ::= #cmdToOp ( Cmd ) [function]
  rule #cmdToOp( + ) => INCVAL
  rule #cmdToOp( - ) => DECVAL
  rule #cmdToOp( , ) => READ
  rule #cmdToOp( . ) => PRINT
  rule #cmdToOp( > ) => INCPTR
  rule #cmdToOp( < ) => DECPTR

//td: can we generalize these? does k have higher order functions?
  syntax List ::= #incElem( List , Int ) [function]
  rule #incElem( (ListItem(X0) XS) , N ) => ListItem(chop(X0 +Int 1)) XS
    requires N ==Int 0
  rule #incElem( (ListItem(X0) XS) , N ) => ListItem(X0) #incElem(XS, N -Int 1)
    requires N >Int 0

  syntax List ::= #decElem( List , Int ) [function]
  rule #decElem( (ListItem(X0) XS) , N ) => ListItem(chop(X0 -Int 1)) XS
    requires N ==Int 0
  rule #decElem( (ListItem(X0) XS) , N ) => ListItem(X0) #decElem(XS, N -Int 1)
    requires N >Int 0

  syntax List ::= #growList( List , Int , KItem ) [function]
  rule #growList( XS , N , _ ) => XS requires N <Int size(XS)
  rule #growList( XS , N , V ) => (XS #growList(ListItem(V), N -Int 1, V))
    requires N >=Int size(XS)

  syntax Int ::= "pow8"
  rule pow8 => 256 [macro]

// TODO: chop ( -1 ) returns -1?
  syntax Int ::= chop( Int )  [function]
  rule chop( I ) => I requires I >=Int 0 andBool I <Int pow8
  rule chop( I ) => I %Int pow8 requires I <Int 0 orBool I >=Int pow8

  syntax List ::= List "[" Int ":=" KItem "]" [function]
  rule (ListItem(X0) XS) [N := X] => ListItem(X) XS
    requires N ==Int 0
  rule (ListItem(X0) XS) [N := X] => ListItem(X0) (XS [N -Int 1 := X])
    requires N >Int 0

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
