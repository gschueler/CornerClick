Historical Readme
=====

by Greg Schueler, 9/12/201.
- - - 

I started working on CornerClick in 2003 with zero knowledge of Objective-C and Cocoa.  I was frustrated by Mac OS X and how there was no quick way of switching between running Applications 
and opening things with just the mouse. I had recently read about [Fitt's Law](http://en.wikipedia.org/wiki/Fitt's_law).

Fitt's Law shows that there are five pixels of the screen that are the fastest pixels to click on
no matter where your cursor is pointed.  They are 1: The pixel directly under the cursor (as the mouse doesn't have to move to pick it) and 2-5: the four corners of the screen.

Each screen corner is essentially an infinitely large target for you to hit.  Moving the cursor into (and beyond) the corner of the screen "traps" it at exactly the corner pixel.  This means that you can quickly jam the cursor into a corner and know that it will settle in exactly one location. Why not put buttons in those locations?

CornerClick started while I was in-between jobs and had ample time to work on it. Once I began 
working full time again it became harder to get time to update CornerClick, but I at least kept the project abreast of new Mac OS X versions as they have come out.

I realized I needed to make this project Open Source so that outstanding bugs and features might
at least be addressed by somebody else.  It took a looong time to get around to this, but I am happy to finally make the source available.  Github is a great place to have coding become social, and so I think it will be a good place for CornerClick to go.

By making it free as in speech as well as in beer, I'm essentially donating it to you.  I will perhaps
at times add features/bugfixes (at a glacial pace I'm sure), but I am essentially leading it onto the iceberg for a goodbye. That said, I use CornerClick 100% of my working hours on my mac(s), and as such I have a vested interest in making sure it stays free from huge bugs and continues working for years to come.

Happy forking,

Greg

p.s. 

I mention that I had zero knowledge of Objective-C and Cocoa as a starting point because CornerClick really was "My First Objective-C Program".  If there are coding style and design quirks, that is my excuse. The code has essentially only evolved slowly from that first starting point, and I haven't done any more refactoring than was necessary to make it work with new OS X versions.