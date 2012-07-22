iDroid-Layout
=============

iDroid-Layout is a port of the Android Layout system to iOS. 

## THIS IS CURRENTLY A PRE-ALPHA EXPERIMENTAL VERSION. DON'T USE IT UNTIL YOU KNOW WHAT YOU ARE DOING!

Why?
----
The main reason for this project was to learn more about the Android layout system and how it works.
Another reason is the lack of a powerful layout system in iOS. Currently it is a pain to build maintainable UI code in iOS. You have the choice between doing your layout in interface builder which is great for static but not powerfull enough for dynamic content, or doing all in code which is difficult to maintain.
In Android layouts can be defined in XML. Views automatically adjust their size while taking into account their content requirements and their parents' size restrictions.


Highlights
----------
- Define complete layouts in XML
- Use all native UI widgets like UIButton, UITextField etc. and even custom subclasses of UIView within the layout XML
- Layout views in linearly (LinearLayout)
- Layout views relatively to each other and to their parents (RelativeLayout)
- Add views to UIScrollViews and let the automatically adjust their content size according to your layout
- Extend the layout system by implementing your own layout container

