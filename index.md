---
layout: layout
title: hentula.com
comments: false
---

<div class="related">
  {% for post in site.posts %}
  <div class=" post-excerpt">
	<h2 class="title">
		<a href="{{ post.url }}">    {{ post.title }}</a> 
	</h2>

	<div class="article-text">
		<table>
			<td>
				<a href="{{ post.url }}"> <img src="{{ post.image }}" width="200" height="200" align="right" /> </a>
				{{ post.description }}
				<br/>
			</td>
 		</table>
	<div class="article-date">
		{{ post.date | date: "%Y-%m-%d" }}
	</div>
	</div>
				<div class="meta">
					<a href="{{ post.url }}#disqus_thread"></a>
				</div>
  </div>
  {% endfor %}
</div>
