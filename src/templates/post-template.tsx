/** @jsx jsx */

import rehypeReact from "rehype-react"
import React from "react"
import { graphql } from "gatsby"
import { Themed, Grid, Divider, Box, Link, jsx } from "theme-ui"
import Layout from '../components/layout';
import CellBlock from '../components/cellBlock';
import Utterances from "utterances-react"
import { useColorMode } from 'theme-ui'

import 'katex/dist/katex.min.css';


export default function Template({pageContext}) {
  const { markdownRemark } = pageContext
  const { frontmatter, htmlAst, timeToRead, tableOfContents } = markdownRemark

  const renderAst = new rehypeReact({
    createElement: React.createElement,
    components: {
      a: Link,
      code: CellBlock,
    },
  }).Compiler

  const issueName = frontmatter.title

  let comments = null;
  if (frontmatter.state && frontmatter.state === 'publish') {
    const [colorMode] = useColorMode()
    let commentTheme = 'github-light';
    // if(colorMode === 'light') {
    //   commentTheme = 'github-light';
    // }
    // else if(colorMode === 'dark') {
    //   commentTheme = 'github-dark'
    // }
    // console.log("colorMode=", colorMode);
    comments = <Utterances
      repo="miguelmartin75/miguelmartin75.github.io"
      issueTerm={issueName}
      label=""
      theme={commentTheme}
      crossorigin="anonymous"
      async={true}
      style={`
      & .utterances {
        max-width: 950px;
      }
    `}
    />;
    //console.log("comments included");
  } else {
    comments = <div>no comments</div>;
  }

  let extraInfo = (
    <div>
      <div>Tags: {frontmatter.tags || "None"}</div>
      <div>State: {frontmatter.state || "None"}</div>
    </div>
  );
  if (frontmatter.state === "publish") {
    extraInfo = (
        <div>Tags: {frontmatter.tags || "None"}</div>
    );
  }

  let paperInfo = null;
  if (frontmatter.source) {
    paperInfo = (
      <div>
        <div>Source: {<Link href={frontmatter.source}>{frontmatter.source || "None"}</Link>}</div>
        <div>Code: {<Link href={frontmatter.code}>{frontmatter.code || "None"}</Link>}</div>
      </div>
    );
  }

  // <Themed.h1 sx={{m: 0}}>{frontmatter.title}</Themed.h1>
  // console.log("HI");
  // console.log(tableOfContents.items);
  // let tocEl = (
  //   <nav>
  //     {
  //       tableOfContents.map(p => {
  //         <li key={p.url}>
  //           <a href={p.url}>{p.title}</a>
  //         </li>
  //       })
  //     }
  //   </nav>
  // )
  // let toc = {__html: tableOfContents}
  // for(var x in tableOfContents.items) {
  //   console.log('toc', x)
  // }

  if(!timeToRead) {
    timeToRead = "<1"
  }

  let minPostfix = "minutes"
  if(timeToRead == 1) {
    minPostfix = "minute"
  }

  
  return (
    <Layout>
      <title>{frontmatter.title}</title>
      <div className="post-container">
        <Box>
          <h1 sx={{m: 0}}>{frontmatter.title}</h1>
          <div
            sx={{
              display: 'grid',
              gridGap: 4,
              gridTemplateColumns: ['auto', '1fr 256px'],
            }}
          >
          <pre sx={{m: 0, p: 0, mt: 10}}><time>{frontmatter.date}</time></pre>
          <pre sx={{textAlign: "right"}}>Time to read: {timeToRead} {minPostfix}</pre>
          </div>
        </Box>
        <Divider></Divider>
        <div className="content">
          <div
            sx={{
              display: 'grid',
              gridGap: 3,
              gridTemplateColumns: `repeat(auto-fit, minmax(128px, 1fr))`,
            }}>
            {extraInfo}
            {paperInfo}
          </div>
          { renderAst(htmlAst) }
          {comments}
        </div>
      </div>
    </Layout>
  )
}
