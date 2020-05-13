module HELLO-WORLD-SPEC
  imports BRAINFUCK

// fails with: Sorts KItem and Int are incompatible

  rule
    <bf>
      <k>
        + + + + + + + + [ > + + + + [ > + + > + + + > + + + > + < < < < - ] > + > + > - > > + [ < ] < - ] > > . > - - - . + + + + + + + . . + + + . > > . < - . < . + + + . - - - - - - . - - - - - - - - . > > + . > + + .
      =>
        .K
      </k>
      <ptr>
        P:Int
      =>
        P +Int 6
      </ptr>
      <mem>
        P |-> 0
        P +Int 1 |-> 0
        P +Int 2 |-> (0 => 72)
        P +Int 3 |-> (0 => 100)
        P +Int 4 |-> (0 => 87)
        P +Int 5 |-> (0 => 33)
        P +Int 6 |-> (0 => 10)
        /* .Map */
      /* => */
        /* P |-> 0 */
        /* P +Int 1 |-> 0 */
        /* P +Int 2 |-> 72 */
        /* P +Int 3 |-> 100 */
        /* P +Int 4 |-> 87 */
        /* P +Int 5 |-> 33 */
        /* P +Int 6 |-> 10 */
      </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output>
        .List
      =>
        ListItem("H")
        ListItem("e")
        ListItem("l")
        ListItem("l")
        ListItem("o")
        ListItem(" ")
        ListItem("W")
        ListItem("o")
        ListItem("r")
        ListItem("l")
        ListItem("d")
        ListItem("!")
        ListItem("\n")
      </output>
    </bf>
  requires P >=Int 0 andBool P <Int 250

endmodule
