import React from "react"
//import MonacoEditor from 'react-monaco-editor';
import SyntaxHighlighter from 'react-syntax-highlighter';
import { docco } from 'react-syntax-highlighter/dist/esm/styles/hljs';

import styled from "styled-components";

const StyledCellBlock = styled.div`
display: grid;
`;

const InlineCellBlock = styled.div`
display: inline;
`;


class CellBlock extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      code: null,
      height: 30,
      maxHeight: 1000,
    }
  }

  renderMonaco(codeText, className) {
    const setCode = (value) => {
      this.setState({code : value});
    }

    const setHeight = (value) => {
      const h = Math.min(value, this.state.maxHeight);
      this.setState({height: h});
      console.log("height set", h, value);
    }

    const execCell = (ed) => {
      if(className.includes("js")) {
        alert(this.state["code"])
      } else {
        alert("not supported");
      }
    };

    const onDidContentSizeChange = (ed) => {
      const h = ed.getModel().getLineCount() * 19;
      setHeight(h);
    };

    const editorDidMount = (editor, mo) => {
      editor.onDidContentSizeChange(() => onDidContentSizeChange(editor));

      editor.addAction({
        id: 'exec-cell',
        label: 'Execute Cell',
        keybindings: [
          mo.KeyMod.CtrlCmd | mo.KeyCode.Enter,
        ],
        precondition: null,
        keybindingContext: null,
        contextMenuGroupId: null,
        contextMenuOrder: 1.5,
        run: execCell,
      });
    };

    const onChange = (newValue, e) => {
      setCode(newValue)
    };

    const options = {
      selectOnLineNumbers: true,
      showUnused: true,
      showDeprecated: true,
      minimap: { enabled: false },
      scrollBeyondLastColumn: 0,
      scrollBeyondLastLine: false,
    };

    // <MonacoEditor
    //   height={this.state.height}
    //   language="python"
    //   theme="vs-dark"
    //   value={codeText}
    //   options={options}
    //   editorDidMount={editorDidMount}
    //   onChange={onChange}
    // />
    return (
      <StyledCellBlock>
        <SyntaxHighlighter class={className} language="python" style={docco}>
          {codeText}
        </SyntaxHighlighter>
      </StyledCellBlock>
    );
  }

  render() {
    let className = null;
    let lang = null;
    var codeText: string = this.state.code;
    if (this.props.className) {
      className = this.props.className;
      lang = className.split("-")[1];
    }
    const {children} = this.props;
    if(!codeText) {
      codeText = children[0];
    }
    const isMultiLine = codeText.endsWith("\n")

    //   const isLangInteractive = className.includes("python") || className.includes("js") ;
    //   if(isLangInteractive && className.includes("interactive")) {
    //     return this.renderMonaco(codeText, className)
    //   }
    // }

    console.log("code=", codeText, isMultiLine)
    if (!isMultiLine) {
      return (
        <InlineCellBlock><code>{codeText}</code></InlineCellBlock>
      )
    }
    return (
      <StyledCellBlock>
        <SyntaxHighlighter language={lang} style={docco}>
          {codeText}
        </SyntaxHighlighter>
      </StyledCellBlock>
    )
  }
}

export default CellBlock;
