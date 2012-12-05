//
//  MainViewController.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "MainViewController.h"
#import <iDroidLayout/iDroidLayout.h>
#import "FormularViewController.h"
#import "LayoutAnimationsViewController.h"
#import "IDLResourceManager.h"

@implementation MainViewController

- (void)dealloc {
    [_tableCellLayoutURL release];
    [_tableView release];
    [_titles release];
    [_descriptions release];
    [super dealloc];
}

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [[[IDLResourceManager alloc] init] autorelease];
    [super viewDidLoad];
    
    _tableCellLayoutURL = [[[NSBundle mainBundle] URLForResource:@"mainCell" withExtension:@"xml"] retain];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    _titles = [[NSArray alloc] initWithObjects:
               @"Formular",
               @"Animations",
               @"ScrollViews",
               @"Interface Builder",
               @"Include", nil];
    _descriptions = [[NSArray alloc] initWithObjects:
                     @"Shows a simple formular implemented using a combination of RelativeLayout and LinearLayout",
                     @"Shows simple layout animations",
                     @"Horizontal and vertical scroll views",
                     @"Layout loaded into a view defined in Interface Builder",
                     @"Layout which includes two other layouts", nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [_tableView release];
    _tableView = nil;
    [_tableCellLayoutURL release];
    _tableCellLayoutURL = nil;
    [_titles release];
    _titles = nil;
    [_descriptions release];
    _descriptions = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MIN([_titles count], [_descriptions count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    IDLTableViewCell *cell = (IDLTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[IDLTableViewCell alloc] initWithLayoutURL:_tableCellLayoutURL reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    UILabel *titleLabel = (UILabel *)[cell.layoutBridge findViewById:@"title"];
    UILabel *descriptionLabel = (UILabel *)[cell.layoutBridge findViewById:@"description"];
    titleLabel.text = [_titles objectAtIndex:indexPath.row];
    descriptionLabel.text = [_descriptions objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 114;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = nil;
    switch (indexPath.row) {
        case 0:
            vc = [[[FormularViewController alloc] initWithLayoutName:@"formular" bundle:nil] autorelease];
            break;
        case 1:
            vc = [[[LayoutAnimationsViewController alloc] initWithLayoutName:@"animations" bundle:nil] autorelease];
            break;
        case 2:
            vc = [[[IDLLayoutViewController alloc] initWithLayoutName:@"scrollviews" bundle:nil] autorelease];
            UIButton *toggleButton = (UIButton *)[vc.view findViewById:@"toggleButton"];
            toggleButton.titleLabel.numberOfLines = 0;
            [toggleButton addTarget:self action:@selector(didPressToggleButton:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 3:
            vc = [[[UIViewController alloc] initWithNibName:@"LayoutFromIB" bundle:nil] autorelease];
            break;
        case 4:
            vc = [[[IDLLayoutViewController alloc] initWithLayoutName:@"includeContainer" bundle:nil] autorelease];
            break;
        default:
            break;
    }
    if (vc != nil) {
        [self.navigationController pushViewController:vc animated:TRUE];
    }
}

- (void)didPressToggleButton:(UIButton *)button {
    IDLTextView *textView = (IDLTextView *)[button.superview findViewById:@"toggleText"];
    
    IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *) textView.layoutParams;
    if (lp.height == IDLLayoutParamsSizeWrapContent) {
        lp.height = 44;
    } else {
        lp.height = IDLLayoutParamsSizeWrapContent;
    }
    textView.layoutParams = lp;
    [UIView animateWithDuration:0.5 animations:^{
        [self.navigationController.topViewController.view layoutIfNeeded];
    }];
}

@end
