//
//  SearchResultController.h
//  WeChatDemo
//
//  Created by lwx on 2016/11/3.
//  Copyright © 2016年 lwx. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FriendModel;
@protocol SearchResultSelectedDelegate <NSObject>

@optional
-(void)selectPersonWithModel:(FriendModel *)model;

@end


@interface SearchResultController : UIViewController<UISearchResultsUpdating>

-(void)updateAddressBookData:(NSArray *)AddressBookDataArray;//得到数据

@property(nonatomic,weak)id<SearchResultSelectedDelegate>delegate;


@end
