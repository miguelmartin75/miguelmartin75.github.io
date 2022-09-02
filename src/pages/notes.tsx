/** @jsx jsx */

import * as React from "react"
import { graphql } from "gatsby"
import Layout from '../components/layout';
import {Container, Text, Link, jsx} from 'theme-ui';

import WebGl from '../components/webgl';
import main from "../toy.js";

// TODO
//import {Helmet} from "react-helmet";

const largerTopicTags = ["ml", "paper-notes", "musing", "idea", "reading-list"];
const largerTopicNames = ["Machine Learning", "Paper Notes", "musing", "idea", "Reading List"];

const NotePage = ({data}) => {
  const notes = data.allMarkdownRemark.edges

  notes.sort((a, b) => {a.node.frontmatter.title < b.node.frontmatter.title});

  //const notesByTag = 

  const notesList = notes.map(temp => {
      const post = temp.node
      const title = post.frontmatter.title || post.frontmatter.slug
      return (
        <li key={post.frontmatter.slug}>
            <article
              class-name="post-list-item"
              itemScope
              itemType="http://schema.org/Article"
            >
              <header>
                <Link href={post.frontmatter.slug} itemProp="url">
                  <span itemProp="headline">{title}</span>
                </Link>
              </header>
              <section>
                <Text
                  dangerouslySetInnerHTML={{
                    __html: post.description || post.excerpt,
                  }}
                  itemProp="description"
                />
              </section>
            </article>
        </li>
      )
  });

  return (
    <Layout>
      <title>Miguel's Notes</title>
      <Container>
        <ul>{notesList}</ul>
      </Container>
      <WebGl func={main} sx={{position: 'absolute', top: 0, left: 0}}></WebGl>
    </Layout>
  )
}

export default NotePage

export const pageQuery = graphql`
  query Notes {
    allMarkdownRemark(filter: {frontmatter: {slug: {regex: "$\/notes.*/g"}}}) {
      edges {
        node {
          frontmatter {
            title
            date
            slug
          }
          children {
            id
          }
        }
      }
    }
  }
`
