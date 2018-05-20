//
//  CycleTableViewModel.h
//  LarryCycleTableView
//
//  Created by Larry Mac Pro on 2018/5/18.
//  Copyright © 2018年 LarryTwofly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CycleTableViewModel : NSObject

@property (nonatomic, copy) NSString *localImgName; //本地图片名字
@property (nonatomic, copy) NSString *imgUrl;       //网络地址
@property (nonatomic, copy) NSString *content;      //内容

@end
