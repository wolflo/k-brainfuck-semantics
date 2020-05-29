[Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) is a notoriously tiny programming language made up of eight commands:
- `+`: Increment the value of the current memory cell
- `-`: Decrement the value of the current memory cell
- `<`: increment the memory pointer
- `>`: decrement the memory pointer
- `[`: if the value of the current memory cell is zero, jump to the matching `]`. Else, continue to the next instruction
- `]`: if the value of the current memory cell is nonzero, jump back to the matching `[`. Else, continue to the next instruction


The [K framework](http://www.kframework.org/) is a "rewrite-based executable semantic framework in which programming languages, type systems and formal analysis tools can be defined". By defining the syntax and semantics of a language in K, you can derive a parser, interpreter, model checker, debugger, symbolic execution engine, and more.


This repo contains a K definition of the Brainfuck language as well as some example Brainfuck programs and specifications used to formally verify properties of these programs.


## Usage
The K tool is required, and can be built using the instructions [here](https://github.com/kframework/k) or installed from a [release](https://github.com/kframework/k/releases).

Build the semantics:
```
kompile brainfuck.k --backend java
```
The haskell backend can be used for proving by substituting `haskell` after the backend flag.

Run a Brainfuck program:
```
krun tests/hello_world.bf
```
Note that the syntax definition currently does not support the "comments anywhere" standard used in Brainfuck, so comments will need to be removed or converted to C-style comments.

Verify a formal specification of a program:
```
kprove tests/specs/concrete/proved/hello-world-spec.k
```

You may also want to include some [lemmas](tests/specs/lemmas.k) to allow K to reason about more complex programs:
```
kprove tests/specs/symbolic/draft/shift-spec.k --def-module LEMMAS
```

## Details
todo

## Resources and previous work
- K formalizations of several esoteric programming languages, including Brainfuck: [esolang-semantics](https://github.com/ellisonch/esolang-semantics)
- The semantics of the Ethereum Virtual Machine, which was used as the primary K reference: [evm-semantics](https://github.com/kframework/evm-semantics)
