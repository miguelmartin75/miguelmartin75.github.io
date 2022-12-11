const { createFilePath } = require(`gatsby-source-filesystem`)
const path = require("path")

exports.onCreateNode = ({ node, getNode, actions }) => {
  const { createNodeField } = actions
  if (node.internal.type === `MarkdownRemark`) {
    const slug = createFilePath({ node, getNode, basePath: `md`, trailingSlash: false})
    if(slug && !slug.includes(".zk")) {
      console.log("slug=", slug)
      createNodeField({
        node,
        name: `slug`,
        value: '/content' + slug.toLowerCase(),
      })
    }
  }
}

exports.createPages = ({graphql, actions}) => {
  const {createPage} = actions
  return new Promise((resolve, _) => {
    resolve(
      graphql(
        `
          {
            posts: allMarkdownRemark {
              nodes {
                htmlAst
                frontmatter {
                  date(formatString: "MMMM DD, YYYY")
                  title
                  state
                  slug
                  tags
                  source
                  code
                }
                fields {
                  slug
                }
              }
            }
          }
        `
      ).then((result) => {
        const nodes = result.data.posts.nodes
        const postTemplate = path.resolve('src/templates/post-template.tsx')

        nodes.forEach(node => {
          if (node.fields) {
            const slug = node.frontmatter.slug || node.fields.slug
            console.log("Path=", path, node)

            createPage({
              path: slug,
              component: postTemplate,
              context: {
                slug: slug,
                markdownRemark: node,
              },
            })
          }
        })
      })
    )
  })
}

