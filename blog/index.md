---
layout: site
html_title: miguel's blog
title: blog
---

<div id="posts">
    {% for post in site.posts %}
        <article class="post">
            <h1 class="post-title">
            <a href="{{ post.url }}">{{post.title}}</a>
            </h1>

            <time datetime="{{ post.date | date_to_xmlschema }}" class="post-date">{{post.data | data_to_string }}</time>
            {{ post.content }}
        </article>
    {% endfor %}
</div>

<div id="post_nav">
    Next | Previous (TODO)
</div>
