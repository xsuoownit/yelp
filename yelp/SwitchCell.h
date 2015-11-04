//
//  SwitchCell.h
//  yelp
//
//  Created by Xin Suo on 11/3/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchCell;

@protocol SwitchCellDelegate <NSObject>

- (void)switchCell: (SwitchCell *)cell didUpdateValue: (BOOL)value;

@end

@interface SwitchCell : UITableViewCell

@property (nonatomic, weak) id<SwitchCellDelegate> delegate;
@property (nonatomic, assign) BOOL on;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)setOn: (BOOL)on animated:(BOOL)animated;

@end
