# design
- written in C (or potentially zig)
- try to get <1k LOC
- output WASM
- use [[WAMR]] as VM

How do we implement:
- APIs
	- WebGPU
		- API
		- Shaders
- Compiler
	- REPL
		- Execute code whilst running
		- Define a function
		- Re-define a function
	- Debugger integration into language?
- Language features


# implementation

## assumptions
input # chars = N
- assume N <= 10^9 (= 10^9 bytes = 1GB of text)
	- 1 LOC = 80 bytes
	- Small Project = 1k LOC = 10^3
	- Medium Project = 10k LOC = 10^4
	- Large Project = 100k LOC = 10^5
	- Very Large Project = 10^6 LOC = 10^6

## tokenizer and parser

- number of nodes and tokens <= N
- we can allocate N tokens

