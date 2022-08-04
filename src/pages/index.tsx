import * as React from "react"
import { Link, graphql } from "gatsby"
import Layout from '../components/layout';
import {Container, Card, Heading, Text} from 'theme-ui';

// TODO
//import {Helmet} from "react-helmet";

const IndexPage = ({data}) => {
  const posts = data.allMarkdownRemark.edges

  const postList = posts.map(temp => {
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
                <Link to={post.frontmatter.slug} itemProp="url">
                  <span itemProp="headline">{title}</span>
                </Link> - {post.frontmatter.date}
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
      <title>Miguel's Blog</title>
      <Container>
        <Text>
          A repository of my writing.
        </Text>
        <ul>{postList}</ul>
      </Container>
    </Layout>
  )
}

export default IndexPage

export const pageQuery = graphql`
  query AllPosts {
    allMarkdownRemark {
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

