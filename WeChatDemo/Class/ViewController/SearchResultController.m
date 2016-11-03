//
//  SearchResultController.m
//  WeChatDemo
//
//  Created by lwx on 2016/11/3.
//  Copyright © 2016年 lwx. All rights reserved.
//

#import "SearchResultController.h"
#import "FriendModel.h"
#import "FriendListCell.h"


#define kMainH [UIScreen mainScreen].bounds.size.height
#define kMainW [UIScreen mainScreen].bounds.size.width

@interface SearchResultController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;//当前VC的TableView
@property (nonatomic, strong) NSMutableArray *dataSource;//数据源
@property (nonatomic, strong) UILabel *footerLabel;//无数据Lable

@end

@implementation SearchResultController

#pragma mark - 懒加载属性
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

- (UITableView *)tableView {
    if (!_tableView) {
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[FriendListCell class] forCellReuseIdentifier:NSStringFromClass([FriendListCell class])];
        
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.bouncesZoom = NO;
        _tableView.delegate = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


- (UILabel *)footerLabel {
    if (!_footerLabel) {
        
        _footerLabel = [UILabel new];
        _footerLabel.textAlignment = NSTextAlignmentCenter;
        _footerLabel.textColor = [UIColor lightGrayColor];
        [self showResultLable];
        
    }
    return _footerLabel;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.frame = CGRectMake(0, -30, kMainW, kMainH);
    self.footerLabel.frame = CGRectMake(0, 0, kMainW, 40);
    


}

#pragma mark - TableView的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FriendListCell class]) forIndexPath:indexPath];
    
    
    if(self.dataSource.count > 0) {
        FriendModel *friends = self.dataSource[indexPath.row];
        cell.model = friends;

    }else{
        if (self.dataSource.count == 0) {
            self.footerLabel.text = @"无结果";
            self.tableView.tableFooterView = self.footerLabel;
        }else{
            self.footerLabel.text = @"";
        }
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FriendModel *friends = self.dataSource[indexPath.row];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (self.delegate&&[self.delegate respondsToSelector:@selector(selectPersonWithModel:)]) {
            [self.delegate selectPersonWithModel:friends];
        }
    }];
}




#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"Entering:%@ ",searchController.searchBar.text);
    
}


-(void)updateAddressBookData:(NSArray *)AddressBookDataArray{
    [self.dataSource removeAllObjects];
    
    [self.dataSource addObjectsFromArray:AddressBookDataArray];
    
    [self.tableView reloadData];
    
    [self showResultLable];

}


- (void)showResultLable {
    
    if (self.dataSource.count==0) {
        _footerLabel.text = @"无结果";
        self.tableView.tableFooterView = _footerLabel;
    }else{
        _footerLabel.text = @"";
    }
    
}









@end
