iDroid-Layout
=============

iDroid-Layout is a port of the Android Layout system to iOS. 

### THIS IS CURRENTLY A PRE-ALPHA EXPERIMENTAL VERSION AND THE API IS NOT STABLE. DON'T USE IT UNTIL YOU KNOW WHAT YOU ARE DOING!

Why?
----
The main reason for this project was to learn more about the Android layout system and how it works.
Another reason is the lack of a powerful layout system in iOS. Currently it is a pain to build maintainable UI code in iOS. You have the choice between doing your layout in interface builder which is great for static but not powerfull enough for dynamic content, or doing all in code which is difficult to maintain.
In Android layouts can be defined in XML. Views automatically adjust their size while taking into account their content requirements and their parents' size restrictions.


Highlights
----------
- Define layouts in XML
- Use native UI widgets like UIButton, UITextField etc. and even custom subclasses of UIView within the layout XML
- Layout views linearly, right to left or top to bottom (LinearLayout)
- Layout views relatively to each other and to their parents (RelativeLayout)
- Add views to UIScrollViews and let them automatically adjust their content size according to your layout
- Extend the layout system by implementing your own layout container
- Load dynamic xml layouts within Interface Builder
- Maintain your resources


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
    
Resources
---------
iDroidLayout contains an advanced resource resolution framework. It allows to reference resources like images, layouts, strings, colors and styles. Resources identifiers allow to (cross-)reference resources. E.g. it allows you to specify texts and images for views within layouts.

##### Resource-Identifier Syntax
The syntax of a resource identifier is the following:
``[<bundle-identifier>:]<resource-type>/<resource-name>[.<resource-subname>]``
- ``<bundle-identifier>`` is the identifier of the bundle which contains the resource. If the bunde-identifier is ommitted, the resource will be searched within the main bundle. To use bundles other than the main bundle, you have to load the bundle at least once before a resource identifier whith this bundle is used.
- ``<resource-type>`` is the resource type (one of ``string``, ``layout``, ``drawable``, ``color`` or ``style``)
- ``<resource-name>`` is the name of te resource file
- ``<resource-subname>`` is an identifier of the specific resource within the resource file. This is only used for some resource types which act as a resource container.

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
Yes, simply use the class name of the view as the xml tag name (e.g. ``<MyCustomView/>``). However, you should implement the ``onMeasureWithWidthMeasureSpec:heightMeasureSpec:`` selector. Otherwise you should not use ``wrap_content`` for the views' width and height.

##### My custom view should not be initialized using init (like the ``IDLLayoutInflater`` usually does). How can I implement a custom initialization?
``IDLLayoutInflater`` creates view objects using a default implementation of the ``IDLViewFactory`` protocol. You can implement a custom view factory by implementing the protocol and setting the ``viewFactory`` property of the ``IDLLayoutInflater``.

##### Can I use xml layouts in ``UITableViewCell``s?
Yes, you can either use ``IDLTableViewCell`` or create a custom UITableViewCell where you inflate your layout into an ``IDLLayoutBridge``.

##### Can I load xml layouts into a view defined in a xib file?
Yes, a layout xml file can be inflated into a view in interface builder. Simple add a plain view in interface builder, set ``IDLLayoutBridge`` as custom class of the newly added view and define a user defined runtime attribute with the name ``layout`` and the name of the xml file (without the file extension) as the value. Check out the example project for more details.

##### Can I re-use layouts within other layouts?
Similar to the android layouting system, you can embed other layouts within a layout XML file using the ``<include />`` and ``<merge />`` tags. Inside the layout to which you want to add the re-usable component, add the <include/> tag. Here's an example:

    <LinearLayout
        layout_width="match_parent"
        layout_height="match_parent"
        orientation="vertical">
        
        <include layout="layoutToInclude"/>
        
        <TextView
            layout_width="match_parent"
            layout_height="wrap_content"
            text="Some text"/>
    </LinearLayout>
    
You can also override all the layout parameters (any ``layout_*`` attributes), the id and the visibility of the included layout's root view by specifying them in the ``<include/>`` tag. For example:

    <include id="title"
             layout_width="match_parent"
             layout_height="match_parent"
             layout="layoutToInclude"
             visibility="gone"/>

XML files always need a single root element. If you have to include multiple views from another single layout file, you need a container as a root element. This is where the ``<merge />`` tag comes into play. It allows you to include multiple views at once, without the need of an extra layout container:

    <merge>
        <TextView
            layout_width="match_parent"
            layout_height="wrap_content"
            text="First text view"/>
        <TextView
            layout_width="match_parent"
            layout_height="wrap_content"
            text="Second text view"/>
    </merge>

Now, when you include this layout in another layout (using the ``<include/>`` tag), the system ignores the ``<merge />`` element and places the two text views directly in the layout, in place of the ``<include/>`` tag.
