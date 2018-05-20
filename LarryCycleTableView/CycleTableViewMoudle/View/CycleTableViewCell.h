//
//  CycleTableViewCell.h
//  LarryCycleTableView
//
//  Created by Larry Mac Pro on 2018/5/18.
//  Copyright © 2018年 LarryTwofly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CycleTableViewModel;
@interface CycleTableViewCell : UITableViewCell
/*
 *参数：model
 *作用：为cell赋（新）值
 */
-(void)setDataWithModel:(CycleTableViewModel *)model;
@end
