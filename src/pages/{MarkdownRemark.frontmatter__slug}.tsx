/** @jsx jsx */

import rehypeReact from "rehype-react"
import React from "react"
import styled from "styled-components";
import { graphql } from "gatsby"
import { Themed, Divider, Box, jsx } from "theme-ui"
import MonacoEditor from 'react-monaco-editor';
import Layout from '../components/layout';
import Utterances from "utterances-react"
import SyntaxHighlighter from 'react-syntax-highlighter';
import { docco } from 'react-syntax-highlighter/dist/esm/styles/hljs';

const StyledCellBlock = styled.div`
//display: flex;
display: grid;
grid-template-columns: 1fr 1fr;
grid-gap: 20px;

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

    return (
      <StyledCellBlock>
        <MonacoEditor
          height={this.state.height}
          language="python"
          theme="vs-dark"
          value={codeText}
          options={options}
          editorDidMount={editorDidMount}
          onChange={onChange}
        />
        <noscript>
          <SyntaxHighlighter class={className} language="python" style={docco}>
            {codeText}
          </SyntaxHighlighter>
        </noscript>
      </StyledCellBlock>
    );
  }

  render() {
    let className = null;
    let lang = null;
    const codeText: string = this.state.code;
    if (this.props.className) {
      className = this.props.className;
      lang = className.split("-")[1];

      const {children} = this.props;
      const isLangInteractive = className.includes("python") || className.includes("js") ;
      if(!codeText) {
        codeText = children[0];
      }
      if(isLangInteractive && className.includes("interactive")) {
        return this.renderMonaco(codeText, className)
      }
    }

    return (
      <StyledCellBlock>
        <SyntaxHighlighter class={className} language={lang} style={docco}>
          {codeText}
        </SyntaxHighlighter>
      </StyledCellBlock>
    )
  }
}


export default function Template({
  data, // this prop will be injected by the GraphQL query below.
}) {
  const { markdownRemark } = data // data.markdownRemark holds your post data
  const { frontmatter, htmlAst } = markdownRemark

  const renderAst = new rehypeReact({
    createElement: React.createElement,
    components: {
      code: CellBlock,
    },
  }).Compiler

  const issueName = frontmatter.slug
  console.log(issueName)

  return (
    <Layout>
      <div className="blog-post">
        <Box>
          <Themed.h1 sx={{m: 0}}>{frontmatter.title}</Themed.h1>
          <pre sx={{m: 0, p: 0}}><time>{frontmatter.date}</time></pre>
        </Box>
        <Divider></Divider>
        <div className="blog-post-content">
          { renderAst(htmlAst) }
        </div>
        <Utterances
          repo="miguelmartin/miguelmartin75.github.io"
          issueTerm={issueName}
          label=""
          theme="github-light"
          crossorigin="anonymous"
          async={false}
          style={`
          & .utterances {
            max-width: 950px;
          }
        `}
        />
      </div>
    </Layout>
  )
}

export const pageQuery = graphql`
  query($id: String!) {
    markdownRemark(id: { eq: $id }) {
      htmlAst
      frontmatter {
        date(formatString: "MMMM DD, YYYY")
        slug
        title
      }
    }
  }
`
