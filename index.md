---
layout: homepage
title: CornerClick
test: test
---

CornerClick
===========

![CornerClick](img/CornerClick.png)

What is CornerClick?
------------

CornerClick allows you to assign actions to each corner of your screen in Mac OS X. Your screen corners can act like four buttons which will never move. You will never miss when you try to click the corner of the screen.

* Right and Left click actions with the same modifiers:  

<a href="screenshots.html">
<img class="img"  src="img/shots/left-right-actions.png" /> 
</a>

The Dock is badly designed from a user interface point of view. If you have a lot of icons in your dock, either your icons are really tiny or you have magnification turned on. Every time you want to launch something new, or just get back to Safari, you have to put on your Dock goggles and hunt for the right icon. The icon you want is never in the right place, or it tries to dodge your mouse when you have magnification turned on.

Simply assign actions to your corners using the CornerClick PreferencePane, then you can easily click in the corners to invoke those actions.

You can also use your mouse's scroll-wheel to select any of the actions you assigned to the corner.

[Read more ...](http://github.com/gschueler/CornerClick#readme)

Source
-------

* [CornerClick on Github](http://github.com/gschueler/CornerClick)
    * Now available under the Apache 2 License.

Download
-------

* [CornerClick 0.9](download.html) - For Mac OS X 10.6 (universal, 32/64-bit)
  
    **Known issue:** Does not start automatically at login.  See [workaround](https://github.com/gschueler/CornerClick/issues/1).

* [CornerClick 0.8.2](download.html#PreviousVersions) - For Mac OS X 10.5

News
------

* [CornerClick Blog](http://cornerclick.blogspot.com) - ([RSS Feed](http://feeds.feedburner.com/Cornerclick))

help!
-----
* [Install](doc/install.html)
* [Uninstall](doc/uninstall.html)


contact
------
* [email me](mailto:&#103;r&#101;&#103;-cornerclick&#64;&#118;a&#114;&#105;o&#46;&#117;&#115;)
* [bugs?](https://github.com/gschueler/CornerClick/issues)


<ul class="posts">
{% for post in site.posts %}
  <li><a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>
