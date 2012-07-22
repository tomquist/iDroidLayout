//
//  MainViewController.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
    NSURL *_tableCellLayoutURL;
    
    NSArray *_titles;
    NSArray *_descriptions;
}

@end
