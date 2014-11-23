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
            <small><time datetime="{{ post.date | date_to_xmlschema }}" class="post-date">{{ post.date | date_to_string }}</time></small>
            </h1>

            {{ post.content }}
        </article>
    {% endfor %}
</div>


<small id="archive"><a href="{{ site.url }}/blog/archive">archive</a></small>
