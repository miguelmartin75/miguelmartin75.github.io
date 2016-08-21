---
layout: blog
html_title: miguel's blog
title: blog
---

<div id="posts">
    {% for post in site.posts %}
        <article class="post">
            <div class="post-title">
                <h1>
                    <a href="{{ post.url }}">{{post.title}}</a>
                </h1>
                <time style="padding-top: 5px" datetime="{{ post.date | date_to_xmlschema }}">
                    {% assign d = post.date | date: "%-d"  %}
                    {{ post.date | date: "%B" }} 
                    {% case d %}
                        {% when '1' or '21' or '31' %}{{ d }}st,
                        {% when '2' or '22' %}{{ d }}nd,
                        {% when '3' or '23' %}{{ d }}rd,
                        {% else %}{{ d }}th,
                    {% endcase %}
                    {{ post.date | date: "%Y" }}
                </time>
            </div>


            {{ post.excerpt }}

            <a href="{{ post.url }}">Continue Reading...</a>
        </article>
    {% endfor %}
</div>
