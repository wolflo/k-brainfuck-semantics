module SHIFT-SPEC
  imports BRAINFUCK

  rule
    <bf>
      <k>
        - > + <
      =>
        .K
      </k>
      <ptr> P:Int </ptr>
      <mem>
        P |-> (M1:Int => M1 -Int 1)
        P +Int 1 |-> (M2 => M2 +Int 1)
      </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output> .List </output>
    </bf>
  requires P >=Int 0 andBool P <Int 29999
    andBool M1 >=Int 1 andBool M1 <Int 256
    andBool M2 >=Int 0 andBool M2 <Int 255

/*   rule */
/*     <bf> */
/*       <k> */
/*         [ - > + < ] */
/*       => */
/*         .K */
/*       </k> */
/*       <ptr> P:Int </ptr> */
/*       <mem> */
/*         P |-> (M1 => 0) */
/*         P +Int 1 |-> (M2 => chop (M2 +Int M1) pow8) */
/*       </mem> */
/*       <env> DEFAULT </env> */
/*       <input> .List </input> */
/*       <output> .List </output> */
/*     </bf> */
/*   requires P >=Int 0 andBool P <Int 29999 */
/*     andBool M1 >=Int 0 andBool M1 <Int 254 */
/*     andBool M2 >=Int 0 andBool M2 <Int 254 */

endmodule
