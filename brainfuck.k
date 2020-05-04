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

endmodule

module BRAINFUCK
  imports DOMAINS
  imports BRAINFUCK-SYNTAX

endmodule
