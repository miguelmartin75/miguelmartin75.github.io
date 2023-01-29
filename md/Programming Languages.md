# Ideas
## Dynamic Data Layout 
	- Related: ECS https://devlog.hexops.com/2022/lets-build-ecs-part-2-databases/

lexer and parser
- token = unique id + location for source code
- node = tagged union
- has variety of types
```
struct AstNode {
	data: union {
		UnaryOp,
		BinaryOp,
		FuncCall,
		FuncDecl,
		TypeDecl,
	}
	tag: NodeType
};
```