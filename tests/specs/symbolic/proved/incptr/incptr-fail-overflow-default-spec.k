module INCPTR-FAIL-OVERFLOW-DEFAULT-SPEC
  imports BRAINFUCK

  rule
    <bf>
      <k>
        >
      =>
        #halt MEMORY_OVERFLOW
      </k>
      <ptr> P:Int </ptr>
      <mem> .Map </mem>
      <env> DEFAULT </env>
      <input> .List </input>
      <output> .List </output>
    </bf>
  requires P >Int 29998

endmodule
