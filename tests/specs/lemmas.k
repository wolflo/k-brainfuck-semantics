requires "../../brainfuck.k"

module LEMMAS
  imports BRAINFUCK

  rule X:Int +Int A -Int B => X +Int (A -Int B) [simplification]
  rule X:Int +Int A +Int B => X +Int (A +Int B) [simplification]

endmodule

