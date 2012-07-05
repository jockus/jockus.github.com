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
		<table>
			<td>
		<img src="{{ post.image }}" width="200" height="200" align="left"></img>
		{{ post.description }}
	</td>
	</table>
	</div>

	<div class="meta">
		<a href="{{ post.url }}#disqus_thread"></a>
	</div>
  </div>
  {% endfor %}
</div>
