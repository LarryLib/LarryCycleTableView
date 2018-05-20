//
//  CycleTableViewVC.m
//  LarryCycleTableView
//
//  Created by Larry Mac Pro on 2018/5/18.
//  Copyright © 2018年 LarryTwofly. All rights reserved.


/*
 *tableview数据无限循环，本地+Url交叉效果实现，支持手动+自动
 */

#import "CycleTableViewVC.h"
#import "CycleTableViewModel.h"
#import "CycleTableViewCell.h"

@interface CycleTableViewVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableV;
@property (nonatomic, strong) NSMutableArray <CycleTableViewModel *>*dataMArr;
@property (nonatomic, assign) BOOL isCycle; //YES:支持循环，NO:不支持循环
@property (nonatomic, assign) BOOL isAuto;  //YES:支持自动滑动，NO:不支持自动滑动

@end

@implementation CycleTableViewVC{
    NSTimer *_timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isAuto = YES;  //设置为支持自动滑动
    self.isCycle = YES; //设置支持循环
    
    [self setUI];
    [self getDataWithFalseData];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopCycle];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Nav
-(void)setNav{
    self.navigationController.navigationBarHidden = YES;    //一般搁viewWillAppear里
}

#pragma mark UI
-(void)setUI{
    self.view.backgroundColor = [UIColor hexStringToColor:@"#ebebeb"];
    [self.view addSubview:self.tableV];
}

#pragma mark PrivateResponeMethod
//开始滑动方法
-(void)startCycle{
    //关闭以前的
    [self stopCycle];
    
    //权限&数据
    if (self.isAuto) {
        if (self.dataMArr.count>0) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(cycle_ing) userInfo:nil repeats:YES];
        }
    }
}
//自动循环滑动方法
-(void)cycle_ing{
    CGPoint point = self.tableV.contentOffset;
    //不支持循环，但支持滑动，数据又少的时候，设置为滑动到底部，就stop
    if (!self.isCycle) {
        if (point.y<self.tableV.contentSize.height-self.tableV.frame.size.height) {
            [self stopCycle];
            return;
        }
    }
    self.tableV.contentOffset = CGPointMake(point.x, point.y+0.25);//此处有bug未解决，即：point.y+0.25,将0.25修改到某一较小值（如0.1），则无法滑动
}
//关闭计时器
-(void)stopCycle{
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

#pragma TableViewDelete&DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.isCycle?MultipleOfSection:self.dataMArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CycleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CycleTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.dataMArr.count==0) {
        [cell setDataWithModel:nil];
        return cell;
    }
    [cell setDataWithModel:self.dataMArr[indexPath.section%self.dataMArr.count]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MyLog(@"%ld",indexPath.section);
}

#pragma mark OtherDelegate

#pragma LazyLoading
//tableView
-(UITableView *)tableV{
    if (!_tableV) {
        _tableV = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableV.delegate = self;
        _tableV.dataSource = self;
        _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)){
            [_tableV setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
        
        //注册cell
        [_tableV registerClass:[CycleTableViewCell class] forCellReuseIdentifier:@"CycleTableViewCell"];
//        [_tableV registerClass:[CycleTableViewCell class] forCellReuseIdentifier:@"CycleTableViewCell_Type2"];
    }
    return _tableV;
}
//tableView的数据源
-(NSMutableArray *)dataMArr{
    if (!_dataMArr) {
        _dataMArr = [NSMutableArray array];
    }
    return _dataMArr;
}

#pragma NetworkData
//获取假数据
-(void)getDataWithFalseData{
    //新数据
    NSArray *otherArr = [self getOtherArr];
    for (int i=0; i<otherArr.count; i++) {
        CycleTableViewModel *model = [CycleTableViewModel new];
        if(i%2==0){
            model.localImgName = otherArr[i];
            model.content = [NSString stringWithFormat:@"本地图片：%d",i+1];
        }else{
            model.imgUrl = otherArr[i];
            model.content = [NSString stringWithFormat:@"网络图片：%d",i+1];
        }
        [self.dataMArr addObject:model];
    }
    [self.tableV reloadData];
    
    //开启循环
    [self startCycle];
}

//其他数据（26字母图+1超大图）
-(NSArray *)getOtherArr{
    return @[@"1",
             @"http://pic31.photophoto.cn/20140415/0006019067030190_b.jpg",
             @"3",
             @"http://imgsrc.baidu.com/imgad/pic/item/2e2eb9389b504fc2b9c88b3eeedde71190ef6d71.jpg",
             @"5",
             @"http://pic.58pic.com/58pic/12/68/87/58PIC5F58PIC2H4.jpg",
             @"7",
             @"http://pic.90sjimg.com/design/01/13/48/71/58f37233f267c.png",
             @"9",
             @"http://img2.baobao88.com/bbfile/allimg/081021/2321510.gif",
             @"11",
             @"http://pic.58pic.com/58pic/14/86/25/13N58PICRT3_1024.jpg",
             @"13",
             @"http://www.kh345.com/upfiles/201501/28/a3f6c923063d6e8a1.png",
             @"15",
             @"http://pic31.photophoto.cn/20140415/0006019000027818_b.jpg",
             @"17",
             @"http://imgsrc.baidu.com/imgad/pic/item/267f9e2f07082838682771deb299a9014d08f1d6.jpg",
             @"19",
             @"http://s8.mogucdn.com/b7/pic/150323/hskgb_ieytmmtfheytmzjrgazdambqmeyde_640x900.jpg_880x999.jpg",
             @"21",
             @"http://en.pimg.jp/012/518/649/1/12518649.jpg",
             @"23",
             @"http://imgsrc.baidu.com/imgad/pic/item/77094b36acaf2edd1479cacc871001e93901930f.jpg",
             @"25",
             @"http://imgsrc.baidu.com/imgad/pic/item/cb8065380cd79123c483ad4fa6345982b2b780ad.jpg",
             @"kongtu",
             @"http://pic2.ooopic.com/12/17/89/17bOOOPIC7c.jpg"];
}

@end
