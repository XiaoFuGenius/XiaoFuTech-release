//
//  XFRefershTableView.m
//  ZhiHuFu
//
//  Created by 胡文峰 on 2018/6/29.
//  Copyright © 2018年 郑炜钢. All rights reserved.
//

#import "XFRefershTableView.h"
#import <XiaoFuTech/XiaoFuTech.h>
#import "MJRefresh.h"

@interface XFRefershTableView ()
@property (nonatomic, assign) CGFloat lastContentHeight;
@end

@implementation XFRefershTableView

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    XFRefershTableView *tableView = [super allocWithZone:zone];
    return tableView;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style]) {

        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.estimatedRowHeight = 0;
            self.estimatedSectionFooterHeight = 0;
            self.estimatedSectionHeaderHeight = 0;
        }

        self.lastContentHeight = 0;
        [self setup_mjHeader];
        [self setup_mjFooter];
    }
    return self;
}

- (void)header_StartRefreshing {
    [self.mj_header beginRefreshing];
}

- (void)header_EndRefreshing {
    [self.mj_header endRefreshing];

    self.lastContentHeight = 0;
    [self.mj_footer resetNoMoreData];
}

- (void)footer_StartRefreshing {
    [self.mj_footer beginRefreshing];
}

- (void)footer_EndRefreshing {
    if (self.contentSize.height > self.lastContentHeight) {
        [self.mj_footer endRefreshing];
    } else {
        [self.mj_footer endRefreshingWithNoMoreData];
    }
    self.lastContentHeight = self.contentSize.height;
}

- (void)footer_allowRefreshing{
    [self.mj_footer resetNoMoreData];
}

- (void)setup_mjHeader
{
    XFWeakSelf(weakSelf);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (weakSelf.refershDelegate &&
            [weakSelf.refershDelegate
             respondsToSelector:@selector(XFRefershTableViewTriggerRefersh:)]) {
            [weakSelf.refershDelegate XFRefershTableViewTriggerRefersh:weakSelf];
        }
    }];

    header.automaticallyChangeAlpha = NO;
    header.stateLabel.hidden = YES;
    header.lastUpdatedTimeLabel.hidden = YES;

    // 设置文字
    [header setTitle:XFLanguageString(@"下拉可以刷新") forState:MJRefreshStateIdle];
    [header setTitle:XFLanguageString(@"松开立即刷新") forState:MJRefreshStatePulling];
    [header setTitle:XFLanguageString(@"刷新ing...") forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeText = ^NSString *(NSDate *lastUpdatedTime) {
        return [weakSelf getLastUpdateTimeString:lastUpdatedTime];
    };

    // 设置字体
    header.stateLabel.font = [UIFont systemFontOfSize:13];
    header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:12];

    // 设置颜色
    header.stateLabel.textColor = XFColor(0x969696, 1.0f);
    header.lastUpdatedTimeLabel.textColor = XFColor(0x969696, 1.0f);
    
    self.mj_header = header;
}

- (void)setup_mjFooter
{
    XFWeakSelf(weakSelf);
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
    if (weakSelf.refershDelegate &&
        [weakSelf.refershDelegate
         respondsToSelector:@selector(XFRefershTableViewTriggerMore:)]) {
            [weakSelf.refershDelegate XFRefershTableViewTriggerMore:weakSelf];
        }
    }];

    // 设置了底部inset
    //self.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    // 忽略掉底部inset
    //footer.ignoredScrollViewContentInsetBottom = 30;
    // 禁止自动加载
    //footer.automaticallyRefresh = NO;

    footer.automaticallyChangeAlpha = YES;

    // 设置文字
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"" forState:MJRefreshStatePulling];
    [footer setTitle:XFLanguageString(@"正在加载") forState:MJRefreshStateRefreshing];
    [footer setTitle:XFLanguageString(@"没有更多了") forState:MJRefreshStateNoMoreData];

    // 设置字体
    footer.stateLabel.font = [UIFont systemFontOfSize:13];

    // 设置颜色
    footer.stateLabel.textColor = XFColor(0x969696, 1.0f);

    self.mj_footer = footer;
}

- (NSCalendar *)currentCalendar
{
    if ([NSCalendar respondsToSelector:@selector(calendarWithIdentifier:)]) {
        return [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    }
    return [NSCalendar currentCalendar];
}

- (NSString *)getLastUpdateTimeString:(NSDate *)lastUpdatedTime
{
    if (lastUpdatedTime) {
        // 1.获得年月日
        NSCalendar *calendar = [self currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute;
        NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:lastUpdatedTime];
        NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];

        // 2.格式化日期
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        BOOL isToday = NO;
        if ([cmp1 day] == [cmp2 day]) { // 今天
            formatter.dateFormat = @" HH:mm";
            isToday = YES;
        } else if ([cmp1 year] == [cmp2 year]) { // 今年
            formatter.dateFormat = @"MM-dd HH:mm";
        } else {
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        }
        NSString *time = [formatter stringFromDate:lastUpdatedTime];

        // 3.显示日期
        if (isToday) {
            return [NSString stringWithFormat:XFLanguageString(@"今天 %@"), time];
        } else {
            return [NSString stringWithFormat:XFLanguageString(@"最后更新：%@"), time];
        }
    } else {
        return XFLanguageString(@"最后更新：无记录");
    }
}

@end
