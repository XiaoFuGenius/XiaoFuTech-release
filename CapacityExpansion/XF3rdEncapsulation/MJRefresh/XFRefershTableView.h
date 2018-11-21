//
//  XFRefershTableView.h
//  ZhiHuFu
//
//  Created by 胡文峰 on 2018/6/29.
//  Copyright © 2018年 郑炜钢. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XFRefershTableView;
@protocol XFRefershTableViewDelegate <NSObject>
@required
- (void)XFRefershTableViewTriggerRefersh:(XFRefershTableView *)tableView;
- (void)XFRefershTableViewTriggerMore:(XFRefershTableView *)tableView;
@end

@interface XFRefershTableView : UITableView
@property(nonatomic, weak) id<XFRefershTableViewDelegate> refershDelegate;

- (void)header_StartRefreshing;
- (void)header_EndRefreshing;

- (void)footer_StartRefreshing;
- (void)footer_EndRefreshing;

- (void)footer_allowRefreshing;
@end
