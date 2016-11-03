//
//  ContactsViewController.m
//  WeChatDemo
//
//  Created by lwx on 2016/11/3.
//  Copyright © 2016年 lwx. All rights reserved.
//

#import "ContactsViewController.h"
#import "FriendModel.h"
#import "FriendListCell.h"
#import "SearchResultController.h"

#import "PinYin4Objc.h"

#define kMainH [UIScreen mainScreen].bounds.size.height
#define kMainW [UIScreen mainScreen].bounds.size.width

@interface ContactsViewController ()<UITableViewDataSource,UITableViewDelegate,SearchResultSelectedDelegate,UISearchBarDelegate> {
    
}

@property (nonatomic, strong) NSArray *lettersArray;//数据的字母数组
@property (nonatomic, strong) NSMutableDictionary *nameDic;
@property (nonatomic, strong) NSMutableArray *results;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *updateArray;
@property (nonatomic, strong) UITableView *friendTableView;//数据展示TableView
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) SearchResultController *resultController;//搜索结果VC


@end

@implementation ContactsViewController

#pragma mark - 懒加载重写get方法
#pragma mark TableView的懒加载
- (UITableView *)friendTableView {
    
    if (!_friendTableView) {
        _friendTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_friendTableView registerClass:[FriendListCell class] forCellReuseIdentifier:NSStringFromClass([FriendListCell class])];
        _friendTableView.delegate = self;
        _friendTableView.dataSource = self;
        [self.view addSubview:_friendTableView];
        _friendTableView.tableHeaderView = self.searchController.searchBar;
        
        _friendTableView.tableFooterView = [UIView new];
        
    }
    return _friendTableView;
}

#pragma mark 搜索结果VC的懒加载
- (SearchResultController *)resultController {
    if (!_resultController) {
        _resultController = [SearchResultController new];
        _resultController.delegate = self;
    }
    return _resultController;
}

#pragma mark tableView的searchBar
- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultController];
        _searchController.searchResultsUpdater = self.resultController;
        _searchController.searchBar.placeholder = @"搜索";
        _searchController.searchBar.delegate = self;
    }
    return _searchController;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dataSource = [[NSMutableArray alloc]init];
    self.updateArray = [[NSMutableArray alloc]init];
    self.lettersArray = [[NSArray alloc]init];
    
    //创建视图
    [self createView];
    
    //加载数据
    [self loadAddressBookData];
    
    
    
}



#pragma mark - table的代理方法
//区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.friendTableView) {
        return self.lettersArray.count;
    }else{
        return 1;
    }
}

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.friendTableView) {
        NSArray *nameArray = [self.nameDic objectForKey:self.lettersArray[section]];
        return nameArray.count;
    }else{
        return self.dataSource.count;
    }
}

//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

//区头高
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.friendTableView) {
        return 20.0;
    }
    return 0;
}


//区头名
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.lettersArray objectAtIndex:section];
}


//cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FriendListCell class]) forIndexPath:indexPath];
    
    if (tableView == self.friendTableView) {
        if (self.dataSource.count) {
            FriendModel *frends = [[self.nameDic objectForKey:[self.lettersArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            cell.model = frends;
        }
    }else{
        
        NSString *userName = self.results[indexPath.row];
        FriendModel *friends = [[FriendModel alloc]init];
        for (NSInteger i = 0 ;i < self.dataSource.count; i++) {
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            
            if ([userName isEqualToString:friends.userName]) {
                [tempArray addObject:friends];
            }
            FriendModel *frends = [tempArray objectAtIndex:0];
            cell.model = frends;
        }
    }
    return cell;
    
}


#pragma mark - 创建视图
- (void)createView {
    
    self.nameDic = [[NSMutableDictionary alloc]init];
    self.results = [[NSMutableArray alloc]init];
    
    //背景视图
    self.friendTableView.frame = CGRectMake(0, 0, kMainW, kMainH);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)loadAddressBookData{
    NSData *friendsData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"AddressBook" ofType:@"json"]]];
    NSDictionary *JSONDic = [NSJSONSerialization JSONObjectWithData:friendsData options:NSJSONReadingAllowFragments error:nil];
    for (NSDictionary *eachDic in JSONDic[@"friends"][@"row"]) {
        [self.dataSource addObject:[[FriendModel alloc] initWithDic:eachDic]];
    }
    [self handleLettersArray];
    [self.friendTableView reloadData];
}



- (void)keyboardWillShow:(NSNotification *)notification {
    //    [_tableView setFrame:CGRectMake(0, kNavbarHeight, kScreenWidth, kScreenHeight)];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    //    [_tableView setFrame:CGRectMake(0, 20, kScreenWidth, kScreenHeight-kNavbarHeight)];
}


- (void)handleLettersArray
{
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]init];
    
    for(FriendModel *friends  in self.dataSource)
    {
        HanyuPinyinOutputFormat *formatter =  [[HanyuPinyinOutputFormat alloc] init];
        formatter.caseType = CaseTypeLowercase;
        formatter.vCharType = VCharTypeWithV;
        formatter.toneType = ToneTypeWithoutTone;
        
        NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:friends.userName withHanyuPinyinOutputFormat:formatter withNSString:@""];
        //        NSLog(@"%@",[[outputPinyin substringToIndex:1] uppercaseString]);
        [tempDic setObject:friends forKey:[[outputPinyin substringToIndex:1] uppercaseString]];
    }
    
    self.lettersArray = tempDic.allKeys;
    
    for (NSString *letter in self.lettersArray) {
        NSMutableArray *tempArry = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i < self.dataSource.count; i++) {
            FriendModel *friends = self.dataSource[i];
            HanyuPinyinOutputFormat *formatter =  [[HanyuPinyinOutputFormat alloc] init];
            formatter.caseType = CaseTypeUppercase;
            formatter.vCharType = VCharTypeWithV;
            formatter.toneType = ToneTypeWithoutTone;
            
            
            NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:friends.userName withHanyuPinyinOutputFormat:formatter withNSString:@""];
            if ([letter isEqualToString:[[outputPinyin substringToIndex:1] uppercaseString]]) {
                [tempArry addObject:friends];
                
            }
            
        }
        [self.nameDic setObject:tempArry forKey:letter];
    }
    
    self.lettersArray = tempDic.allKeys;
    NSComparator cmptr = ^(id obj1, id obj2){
        if ([obj1 characterAtIndex:0] > [obj2 characterAtIndex:0]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 characterAtIndex:0] < [obj2 characterAtIndex:0]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    self.lettersArray = [[NSMutableArray alloc]initWithArray:[self.lettersArray sortedArrayUsingComparator:cmptr]];
}


#pragma mark - table表索引代理方法
//表索引对应的index
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.friendTableView) {
        NSInteger count = 0;
        for(NSString *letter in self.lettersArray)
        {
            if([letter isEqualToString:title])
            {
                return count;
            }
            count++;
        }
        return 0;
    }
    else{
        return 0;
    }
}

//表索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.friendTableView) {
        return self.lettersArray;
        
    }else{
        return nil;
    }
}


#pragma mark - UISearchBarDelegate
//开始编辑
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    NSLog(@"SearchBar开始编辑");
}

//文本改变
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText) {
        
        [self.updateArray removeAllObjects];
        if ([PinyinHelper isIncludeChineseInString:searchText]) {// 中文
            for(int i = 0;i < self.dataSource.count;i++)
            {
                FriendModel *friends = self.dataSource[i];
                if ([friends.userName rangeOfString:searchText].location != NSNotFound) {
                    [self.updateArray addObject:friends];
                }
                
            }
        }else{//拼音
            for(int i = 0;i < self.dataSource.count;i++)
            {
                HanyuPinyinOutputFormat *formatter =  [[HanyuPinyinOutputFormat alloc] init];
                formatter.caseType = CaseTypeUppercase;
                formatter.vCharType = VCharTypeWithV;
                formatter.toneType = ToneTypeWithoutTone;
                
                FriendModel *friends = self.dataSource[i];
                
                NSString *outputPinyin=[[PinyinHelper toHanyuPinyinStringWithNSString:friends.userName withHanyuPinyinOutputFormat:formatter withNSString:@""] lowercaseString];
                
                
                if ([[outputPinyin lowercaseString]rangeOfString:[searchText lowercaseString]].location!=NSNotFound) {
                    [self.updateArray addObject:friends];
                }
            }
        }
    }
    
    NSLog(@"%@",self.updateArray);
    [self.resultController updateAddressBookData:self.updateArray];
}

//SearchBar应该开始编辑
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.searchController.searchBar.showsCancelButton = YES;
    UIButton *canceLBtn = [self.searchController.searchBar valueForKey:@"cancelButton"];
    [canceLBtn setTitle:@"取消" forState:UIControlStateNormal];
    [canceLBtn setTitleColor:[UIColor colorWithRed:14.0/255.0 green:180.0/255.0 blue:0.0/255.0 alpha:1.00] forState:UIControlStateNormal];
    searchBar.showsCancelButton = YES;
    return YES;
}

//SearchBar结束编辑
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}


//点击搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

//点击取消按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    
    [searchBar resignFirstResponder];
}




#pragma mark - SearchResultController的代理方法
//选择某条数据
-(void)selectPersonWithModel:(FriendModel *)model {
    NSLog(@"%@",model.userName);
    self.searchController.searchBar.text = @"";
}


@end
















