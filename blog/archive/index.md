---
layout: site
html_title: blog archive
title: archive
---

<h2>Blog Posts</h2>

                    
{% for post in site.posts %}
- <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date_to_string }}</time> [{{ post.title }}]({{ post.url }})
{% endfor %}
