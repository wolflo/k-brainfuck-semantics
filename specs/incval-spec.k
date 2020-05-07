module INCVAL-SPEC
  imports BRAINFUCK
  rule
    <bf>
      <k>
        +
      =>
        .K
      </k>
      <ptr>    P:Int       </ptr>
      <mem>
        .Map
      =>
        P |-> 1
      </mem>
      <env>    DEFAULT     </env>
      <input>  .List       </input>
      <output> .List </output>
    </bf>
  requires P >=Int 0 andBool P <=Int 255
endmodule
