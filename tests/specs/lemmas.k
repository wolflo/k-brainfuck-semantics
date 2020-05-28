requires "../../brainfuck.k"

module LEMMAS
  imports LEMMAS-JAVA
  imports LEMMAS-HASKELL

  rule N +Int 0 => N  [simplification]
  rule N -Int 0 => N  [simplification]
  rule N -Int N => 0  [simplification]

  rule (chop I1 M) +Int I2 => chop (I1 +Int I2) M [simplification]
  rule chop _ _ >=Int 0 => true [simplification]
  rule chop _ M <Int M  => true [simplification]

endmodule

module LEMMAS-JAVA [symbolic, kast]
  imports BRAINFUCK
  imports K-REFLECTION

  rule (A +Int I2) +Int I3 => A +Int (I2 +Int I3) when notBool #isConcrete(A) andBool #isConcrete(I2) andBool #isConcrete(I3)  [simplification]
  rule (A +Int I2) -Int I3 => A +Int (I2 -Int I3) when notBool #isConcrete(A) andBool #isConcrete(I2) andBool #isConcrete(I3)  [simplification]
  rule (A -Int I2) -Int I3 => A -Int (I2 +Int I3) when notBool #isConcrete(A) andBool #isConcrete(I2) andBool #isConcrete(I3)  [simplification]

endmodule

module LEMMAS-HASKELL [symbolic, kore]
  imports BRAINFUCK

  rule (A +Int I2) +Int I3 => A +Int (I2 +Int I3) [concrete(I2, I3), symbolic(A), simplification]
  rule (A +Int I2) -Int I3 => A +Int (I2 -Int I3) [concrete(I2, I3), symbolic(A), simplification]
  rule (A -Int I2) -Int I3 => A -Int (I2 +Int I3) [concrete(I2, I3), symbolic(A), simplification]

endmodule
