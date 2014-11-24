---
layout: blog
html_title: blog archive
title: archive
---

<h2>Blog Posts</h2>
                    
{% for post in site.posts %}
- <small><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date_to_string }}</time></small> [{{ post.title }}]({{ post.url }})
{% endfor %}
