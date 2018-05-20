//
//  CycleTableViewCell.m
//  LarryCycleTableView
//
//  Created by Larry Mac Pro on 2018/5/18.
//  Copyright © 2018年 LarryTwofly. All rights reserved.
//

#import "CycleTableViewCell.h"
#import "CycleTableViewModel.h"

@interface CycleTableViewCell ()

@property (nonatomic, strong) UIImageView *logoImgV;    //图片（来源网络或者本地）
@property (nonatomic, strong) UILabel *contentLab;      //内容label

@end

@implementation CycleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = [UIColor hexStringToColor:@"#ffffff"];
        [self logoImgV];
        [self contentLab];
        
    }
    return self;
}

#pragma mark LazyLoading
-(UIImageView *)logoImgV{
    if (!_logoImgV) {
        _logoImgV = [UIImageView new];
        [self.contentView addSubview:_logoImgV];
        [_logoImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(10);
            make.width.height.mas_equalTo(90);
            make.bottom.mas_equalTo(-10);
        }];
    }
    return _logoImgV;
}
-(UILabel *)contentLab{
    if (!_contentLab) {
        _contentLab = [UILabel new];
        _contentLab.backgroundColor = [UIColor clearColor];
        _contentLab.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        _contentLab.textColor = [UIColor colorWithHexString:@"#222222"];
        _contentLab.textAlignment = 0;
        _contentLab.numberOfLines = 0;
        _contentLab.text = @" ";
        [self.contentView addSubview:_contentLab];
        [_contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.logoImgV);
            make.left.mas_equalTo(self.logoImgV.mas_right).mas_offset(12);
            make.right.mas_equalTo(-10);
        }];
    }
    return _contentLab;
}

#pragma mark cell的刷新数据方法
/*
 *参数：model
 *作用：为cell赋（新）值
 */
-(void)setDataWithModel:(CycleTableViewModel *)model{
    //nil
    if (!model) {
        self.logoImgV.image = [UIImage imageNamed:@""];
        self.contentLab.text = @"";
        return;
    }

    //图片：本地or网络
    if (model.localImgName.length>0) {
        [self.logoImgV sd_setImageWithURL:nil];//使logoImgV以前设置的图片无效，我还需要查看内部实现机制（sd_removeActivityIndicator）
        self.logoImgV.image = [UIImage imageNamed:model.localImgName];
    }else{
        [self.logoImgV sd_setImageWithURL:[NSURL URLWithString:model.imgUrl]];
    }
    //内容
    self.contentLab.text = @"";
    if (model.content.length>0) {
        self.contentLab.text = model.content;
    }
}

#pragma mark 以下方法注释即可，当前cell不需要，仅测试使用
/*
 *测试：通过sd_setImageWithURL为imageView一下子赋多个url
 *效果：imageView展示的总是sd_setImageWithURL最后一次赋值的url图
 *初步结论：sd内部以imageView为key来管理其对应的图片下载线程。当有新的url赋值后，则原有的线程将终止。保证了最新赋值为最终效果
 *拓展使用：可使用sd_setImageWithURL方法传入空的url，以结束与对应imageView：原来的、其他的、所有的网络下载
 */
-(void)SD_OneTest{
    NSArray *urlArr = @[@"http://pic31.photophoto.cn/20140415/0006019067030190_b.jpg",
                        @"http://imgsrc.baidu.com/imgad/pic/item/2e2eb9389b504fc2b9c88b3eeedde71190ef6d71.jpg",
                        @"http://pic.58pic.com/58pic/12/68/87/58PIC5F58PIC2H4.jpg",
                        @"http://pic.90sjimg.com/design/01/13/48/71/58f37233f267c.png",
                        @"http://img2.baobao88.com/bbfile/allimg/081021/2321510.gif",
                        @"http://pic.58pic.com/58pic/14/86/25/13N58PICRT3_1024.jpg",
                        @"http://www.kh345.com/upfiles/201501/28/a3f6c923063d6e8a1.png",
                        @"http://pic31.photophoto.cn/20140415/0006019000027818_b.jpg",
                        @"http://imgsrc.baidu.com/imgad/pic/item/267f9e2f07082838682771deb299a9014d08f1d6.jpg",
                        @"http://s8.mogucdn.com/b7/pic/150323/hskgb_ieytmmtfheytmzjrgazdambqmeyde_640x900.jpg_880x999.jpg",
                        @"http://en.pimg.jp/012/518/649/1/12518649.jpg",
                        @"http://imgsrc.baidu.com/imgad/pic/item/77094b36acaf2edd1479cacc871001e93901930f.jpg",
                        @"http://imgsrc.baidu.com/imgad/pic/item/cb8065380cd79123c483ad4fa6345982b2b780ad.jpg",
                        @"http://pic2.ooopic.com/12/17/89/17bOOOPIC7c.jpg"];//较大图
    
    for (int i=0; i<arc4random()%urlArr.count; i++) {
        [self.logoImgV sd_setImageWithURL:[NSURL URLWithString:urlArr[i]]];
    }
}

/*
 *测试：先本地后nil
 *效果：展示图片为空白
 *初步结论：同SD_OneTest
 */
-(void)SD_TwoTest{
    self.logoImgV.image = [UIImage imageNamed:@"1"];
    [self.logoImgV sd_setImageWithURL:nil];
}

/*
 *测试：先网络后nil
 *效果：展示图片为空白
 *初步结论：同SD_OneTest
 */
-(void)SD_ThreeTest{
    [self.logoImgV sd_setImageWithURL:[NSURL URLWithString:@"http://pic2.ooopic.com/12/17/89/17bOOOPIC7c.jpg"]];
    [self.logoImgV sd_setImageWithURL:nil];
}
@end
