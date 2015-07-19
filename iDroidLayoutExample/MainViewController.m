//
//  MainViewController.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "MainViewController.h"
#import "iDroidLayout.h" // iDroidLayout
#import "FormularViewController.h"
#import "LayoutAnimationsViewController.h"
#import "IDLResourceManager.h"
#import "CollectionViewExampleViewController.h"

@implementation MainViewController


- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableCellLayoutURL = [[NSBundle mainBundle] URLForResource:@"mainCell" withExtension:@"xml"];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    _titles = [[IDLResourceManager currentResourceManager] stringArrayForIdentifier:@"@array/values.main_menu_titles"];
    _descriptions = [[IDLResourceManager currentResourceManager] stringArrayForIdentifier:@"@array/values.main_menu_descriptions"];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    _tableView = nil;
    _tableCellLayoutURL = nil;
    _titles = nil;
    _descriptions = nil;
}

- (void)setupCell:(IDLTableViewCell *)cell forRow:(NSInteger)row {
    UILabel *titleLabel = (UILabel *)[cell.layoutBridge findViewById:@"title"];
    UILabel *descriptionLabel = (UILabel *)[cell.layoutBridge findViewById:@"description"];
    titleLabel.text = [_titles objectAtIndex:row];
    descriptionLabel.text = [_descriptions objectAtIndex:row];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MIN([_titles count], [_descriptions count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    IDLTableViewCell *cell = (IDLTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[IDLTableViewCell alloc] initWithLayoutURL:_tableCellLayoutURL reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [self setupCell:cell forRow:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static IDLTableViewCell *prototypeCell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        prototypeCell = [[IDLTableViewCell alloc] initWithLayoutURL:_tableCellLayoutURL reuseIdentifier:nil];
        prototypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    });
    [self setupCell:prototypeCell forRow:indexPath.row];
    return [prototypeCell requiredHeightInView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    UIViewController *vc = nil;
    switch (indexPath.row) {
        case 0:
            vc = [[FormularViewController alloc] initWithLayoutName:@"formular" bundle:nil];
            break;
        case 1:
            vc = [[LayoutAnimationsViewController alloc] initWithLayoutName:@"animations" bundle:nil];
            break;
        case 2: {
            vc = [[IDLLayoutViewController alloc] initWithLayoutName:@"scrollviews" bundle:nil];
            UIButton *toggleButton = (UIButton *)[vc.view findViewById:@"toggleButton"];
            toggleButton.titleLabel.numberOfLines = 0;
            [toggleButton addTarget:self action:@selector(didPressToggleButton:) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        case 3:
            vc = [[UIViewController alloc] initWithNibName:@"LayoutFromIB" bundle:nil];
            break;
        case 4:
            vc = [[IDLLayoutViewController alloc] initWithLayoutName:@"includeContainer" bundle:nil];
            break;
        case 5: {
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            vc = [[CollectionViewExampleViewController alloc] initWithCollectionViewLayout:layout];
            break;
        }
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
