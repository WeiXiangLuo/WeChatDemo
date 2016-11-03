//
//  FriendListCell.m
//  WeChatDemo
//
//  Created by lwx on 2016/11/3.
//  Copyright © 2016年 lwx. All rights reserved.
//

#import "FriendListCell.h"
#import "FriendModel.h"
#import "UIImageView+WebCache.h"

@interface FriendListCell () {
    UILabel *_lable;
    UIImageView *_headImg;
}




@end

@implementation FriendListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createView];
    }
    return self;
}

- (void)createView {
    
    UILabel *lable = [UILabel new];
    [self.contentView addSubview:lable];
    _lable = lable;
    
    UIImageView *img = [UIImageView new];
    [self.contentView addSubview:img];
    img.backgroundColor = [UIColor lightGrayColor];
    img.clipsToBounds = YES;
    _headImg = img;
}

- (void)setModel:(FriendModel *)model {
    if (_model != model) {
        _model = model;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_model) {
        
        _headImg.frame = CGRectMake(8, 8, 38, 38);
        [_headImg sd_setImageWithURL:[NSURL URLWithString:_model.photo]];
        
        _lable.frame = CGRectMake(58, 7, self.bounds.size.width - 70, 40);
        _lable.text = _model.userName;
    }
    
}








@end
