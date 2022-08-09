/** @jsx jsx */

import rehypeReact from "rehype-react"
import React from "react"
import { graphql } from "gatsby"
import { Themed, Divider, Box, Link, jsx } from "theme-ui"
import Layout from '../components/layout';
import CellBlock from '../components/cellBlock';
import Utterances from "utterances-react"
import { useColorMode } from 'theme-ui'

import 'katex/dist/katex.min.css';


export default function Template({
  data, // this prop will be injected by the GraphQL query below.
}) {
  const { markdownRemark } = data // data.markdownRemark holds your post data
  const { frontmatter, htmlAst } = markdownRemark

  const renderAst = new rehypeReact({
    createElement: React.createElement,
    components: {
      a: Link,
      code: CellBlock,
    },
  }).Compiler

  const issueName = frontmatter.title

  let comments = null;
  //console.log("frontmatter=", frontmatter);
  if (frontmatter.state && frontmatter.state === 'final') {
    const [colorMode] = useColorMode()
    let commentTheme;
    if(colorMode === 'light') {
      commentTheme = 'github-light'
    }
    else if(colorMode === 'dark') {
      commentTheme = 'github-dark'
    }
    //comments = <div>with comments</div>;
    comments = <Utterances
      repo="miguelmartin/miguelmartin75.github.io"
      issueTerm={issueName}
      label=""
      theme={commentTheme}
      crossorigin="anonymous"
      async={false}
      style={`
      & .utterances {
        max-width: 950px;
      }
    `}
    />;
  } else {
    //comments = <div>no comments</div>;
  }

  return (
    <Layout>
      <div className="post-container">
        <Box>
          <Themed.h1 sx={{m: 0}}>{frontmatter.title}</Themed.h1>
          <pre sx={{m: 0, p: 0, mt: 10}}><time>{frontmatter.date}</time></pre>
        </Box>
        <Divider></Divider>
        <div className="content">
          { renderAst(htmlAst) }
        </div>
        {comments}
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
        state
      }
    }
  }
`
