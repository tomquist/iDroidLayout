iDroid-Layout
=============

iDroid-Layout is a port of the Android Layout system to iOS. 

### THIS IS CURRENTLY A PRE-ALPHA EXPERIMENTAL VERSION. DON'T USE IT UNTIL YOU KNOW WHAT YOU ARE DOING!

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


Getting started
---------------
iDroid-Layout is build into a cocoa framework. To install iDroid-Layout, simply copy the iDroidLayout.framework directory into your project. Then drag&drop it into the "Link Binary With Libraries" section within your Build Phases. You also have to add the framework to the "Copy Bundle Resources" section. To use the iDroid-Layout API you have to import the header "iDroidLayout.h" where necessary.

Now everything is set up to use iDroid-Layout.

Defining and using a layout with iDroid-Layout can be done in two simple steps:

1. Create a layout xml file which contains your view hierarchy. E.g.

        <LinearLayout
            layout_width="match_parent"
            layout_height="wrap_content"
            orientation="vertical"
            padding="10">
            <LinearLayout
                layout_width="match_parent"
                layout_height="wrap_content"
                orientation="horizontal">
                <TextView
                    id="text"
                    layout_width="wrap_content"
                    layout_height="wrap_content"
                    text="Some text"
                    background="#00000000"/>
                <TextView
                    id="otherText"
                    layout_width="match_parent"
                    layout_height="match_parent"
                    background="#ff0000"/>
            </LinearLayout>
            <UIButton
                id="button"
                layout_width="100"
                layout_height="30"
                layout_gravity="center_horizontal"
                layout_marginTop="10"
                text="Click me"/>
        </LinearLayout>

2. Create an instance of IDLLayoutViewController:

        IDLLayoutViewController *vc = [[IDLLayoutViewController alloc] initWithLayoutName:@"myLayout" bundle:nil];
        [self.navigationController pushViewController:vc animated:TRUE];
        [vc release];
    


Questions & Answers
-------------------
##### I don't want my whole view hierarchy to be loaded from a layout XML. How can I load a layout into a specific part of my existing view hierarchy?
``IDLLayoutBridge`` is a UIView which acts as a bridge between the plain old view layout mechanism and the iDroid-Layout mechanism. First you have to create an IDLLayoutBridge object and add it to your view hierarchy. Now you can load the xml layout into the ``IDLLayoutBridge`` view using ``IDLLayoutInflater``:


    IDLLayoutBridge *bridge = [[IDLLayoutBridge alloc] initWithFrame:CGRectMake(100, 100, 120, 220)];
    IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
    [inflater inflateURL:[[NSBundle mainBundle] URLForResource:@"myLayout" withExtension:@"xml"] intoRootView:bridge attachToRoot:TRUE];
    [inflater release];
    [self.view addSubview:bridge];
    [bridge release];


##### Can I use native views?
Yes, you can use native views. Simply use the class name of the view as the xml tag name (e.g. ``<UIButton/>``). However, for some of the native views the ``onMeasureWithWidthMeasureSpec:heightMeasureSpec:`` selector is not yet implemented, so you should not use ``wrap_content`` for the view's width and height.

##### Can I use custom views?
Yes, simply use the class name of the view as the xml tag name (e.g. <MyCustomView/>). However, you should implement the ``onMeasureWithWidthMeasureSpec:heightMeasureSpec:`` selector. Otherwise you should not use ``wrap_content`` for the views' width and height.

##### My custom view should not be initialized using init (like the ``IDLLayoutInflater`` usually does). How can I implement a custom initialization?
``IDLLayoutInflater`` creates view objects using a default implementation of the ``IDLViewFactory`` protocol. You can implement a custom view factory by implementing the protocol and setting the ``viewFactory`` property of the ``IDLLayoutInflater``.

