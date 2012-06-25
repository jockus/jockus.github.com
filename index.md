---
layout: layout
title: hentula.com
comments: false
---

<div class="related">
  {% for post in site.posts %}
  <div class=" post-excerpt">
	<h2 class="title">
		<a href="{{ post.url }}">{{ post.title }}</a> 
	</h2>

	<div class="article-text">
		{{ post.content | replace:'more start -->','' | replace:'<!-- more end','' }}
	</div>

	<div class="meta">
		<a href="{{ post.url }}#disqus_thread"></a>
	</div>
  </div>
  {% endfor %}
</div>
