//
//  TutorTaskViewController.m
//  babyfaq
//
//  Created by PRO on 14-1-2.
//  Copyright (c) 2014年 sina. All rights reserved.
//

#import "TutorTaskViewController.h"
#import "TasksViewController.h"
#import "DetailsViewController.h"
#import "WebViewController.h"

@interface TutorTaskViewController ()

@end

@implementation TutorTaskViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _searchBar.hidden = YES;
    //handle data
    //根据时间计算出一个INDEX， 由此INDEX做参数来获取对应的文件数据
    _pageIndex = 1;
    
    NSString* string = [self loadFile:[NSString stringWithFormat:@"%d.txt", _pageIndex]];
    NSDictionary* dic = [self toJSONValue:string];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        TutorSectionModel* model = [[TutorSectionModel  alloc] initWithDataDic:dic];
        self.tutorModel = model;
        [model release];
    }
    
    //task
    NSString* taskJson = [self toJSONValue:[self loadFile:@"task.json"]];
    NSArray *taskArr = [taskJson objectForKey:@"task"];  
    if (taskArr != nil && [taskArr isKindOfClass:[NSArray class]] && taskArr.count > 0) {
        self.tasksData = [[NSMutableArray alloc] initWithCapacity:taskArr.count];
        for (NSDictionary* taskDic in taskArr) {
            TaskModel* model = [[TaskModel  alloc] initWithDataDic:taskDic];
            [_tasksData addObject:model];
            if ([model.weekID integerValue] == _pageIndex) {
                self.curTask = model;
            }
            [model release];
        }
    }
}


- (NSString*)loadFile:(NSString*)file
{
    //NSArray* documentPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	//NSString* documentPath = [documentPathArray objectAtIndex:0];
    //documentPath = [documentPath stringByAppendingPathComponent:file];
   
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //if(![fileManager fileExistsAtPath:documentPath])
    //{
        //if not in document dir ,then copy this file from bundle to document dir
        NSString *bundleFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:file];
        
        NSError *error = nil;
        //[fileManager copyItemAtPath:bundleFile toPath:documentPath error:&error];
        if(error)
        {
            NSLog(@"File copyItemAtPath error: %@", error.localizedFailureReason);
            return @"";
        }
    //}
    
    //file opened
    NSData* reader = [NSData dataWithContentsOfFile:bundleFile];
    NSString* text = [[NSString alloc] initWithData:reader encoding:NSUTF8StringEncoding];
    NSString* retval = [self cleanString:text];
    [text release];
    
    //trim header and tail usless thing
    NSRange range = [retval rangeOfString:@"}" options:NSBackwardsSearch];
    retval = [retval substringToIndex:range.location+1];
    range = [retval rangeOfString:@"{" options:NSCaseInsensitiveSearch];
    retval = [retval substringFromIndex:range.location];
    
    return retval;
}

//去掉从文件读取到的\r \n
- (NSString *)cleanString:(NSString *)str {
    if (str == nil) {
        return @"";
    }
    
    NSMutableString *cleanString = [NSMutableString stringWithString:str];
    [cleanString replaceOccurrencesOfString:@"\n" withString:@""
                                    options:NSCaseInsensitiveSearch
                                      range:NSMakeRange(0, [cleanString length])];
    [cleanString replaceOccurrencesOfString:@"\r" withString:@""
                                    options:NSCaseInsensitiveSearch
                                      range:NSMakeRange(0, [cleanString length])];
    return cleanString;
}

//NSString to json
-(id)toJSONValue:(NSString*)string;
{
    if(string == nil || string.length <= 0)
        return nil;
    
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error != nil) return nil;
    return result;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init navigation item

- (void)initNavigationTitleItem
{
    [super initNavigationTitleItem];
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    [label setText:@"全程指导"];
}

- (void)initOfflineView
{
 //do nothing
}

- (void)initNavigationLeftItem
{
    //nothing
}

- (void)initNavigationRightItem
{
    UIButton *spaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    spaceBtn.frame = CGRectMake(0, 13, 2, 2);
    UIBarButtonItem* leftItem = [[[UIBarButtonItem alloc] initWithCustomView:spaceBtn] autorelease];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 20, 20);
    
    [rightBtn setTitle:@"任务" forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"btn_setting"] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    NSArray* items = @[leftItem, rightBarButtonItem];
    
    
    float osVer = [[UIDevice currentDevice].systemVersion floatValue];
    if (osVer >= 5.0) {
        self.navigationItem.rightBarButtonItems = items;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    
    MW_RELEASE(rightBarButtonItem);
}

- (void) rightBtnClick : (UIButton*)sender
{
    TasksViewController* tasksVC = [[TasksViewController alloc] initWithNibName:@"TasksViewController" bundle:nil];
    tasksVC.tasksData = _tasksData;
    [self.navigationController pushViewController:tasksVC animated:YES];
    [tasksVC release];
    
    //test webview
//    WebViewController* web = [[WebViewController alloc] initWithURL:@"http://baby.sina.com.cn/immunity/08/2805/0754112136.shtml"];
//    [self.navigationController pushViewController:web animated:YES];
//    [web release];
}

- (void)dealloc {
    [_tutorTable release];
    self.tutorModel = nil;
    self.curTask = nil;
    self.tasksData = nil;
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTutorTable:nil];
    [super viewDidUnload];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = self.tutorModel.sectionsData.count + 1;
    int section = indexPath.section;
    
    if (section == index) { //task cell
        return 50;
    }
    return 150;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = indexPath.section;
    if (index == 0) { //for test
        DetailsViewController* dVC = [[DetailsViewController alloc] initWithNibName:@"DetailsViewController" bundle:nil];
        dVC.secModel = [self.tutorModel.sectionsData objectAtIndex:index];
        [self.navigationController pushViewController:dVC animated:YES];
        [dVC release];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int index = self.tutorModel.sectionsData.count + 1;
    
    if (section == index) { //task cell
        return self.curTask.tasksData.count;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = self.tutorModel.sectionsData.count + 1;
    
    int sec = indexPath.section;
    
    NSLog(@"cellForRowAtIndexPath rowNum:%d", sec);
    
    static NSString *userIdentifier = @"tutorcell";
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:userIdentifier];
    if (cell==nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier] autorelease];
    }
    if (sec == 0) {//head
        NSString* text = nil;
        NSString* summary = nil;
        
        if (self.tutorModel.summary != nil) {
            summary = self.tutorModel.summary;
        }
        if (self.tutorModel.text != nil) {
            text = self.tutorModel.text;
        }
        
        if (summary) {
            cell.textLabel.text = summary;
        }
        else if (text) {
            cell.textLabel.text = @"截取30个字，后面的删掉，到详情页查看";
        }
    }
    else if (sec < index)
    {
        NSString* text = nil;
        NSString* summary = nil;
        
        SectionModel* model = [self.tutorModel.sectionsData objectAtIndex:sec-1];
        if (model.summary != nil) {
            summary = model.summary;
        }
        if (model.text != nil) {
            text = model.text;
        }
        
        if (summary) {
            cell.textLabel.text = summary;
        }
        else
            cell.textLabel.text = @"正文在此，诸神退位";
        
    }
    else //task cell
    {
        int row = indexPath.row;
        TaskDetailModel* task = [self.curTask.tasksData objectAtIndex:row];
        if (task) {
            cell.textLabel.text = task.name;
        }
    }
    
    return  cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tutorModel.sectionsData.count + 2;//one for header,and one for task
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    int index = self.tutorModel.sectionsData.count + 1;
    if (section == 0) {//head
        return self.tutorModel.title;
    }
    else if (section < index) {
        SectionModel* model = [self.tutorModel.sectionsData objectAtIndex:section-1];
        if (model) {
            return model.title;
        }
    }
    else//task
    {
        return [NSString stringWithFormat:@"本期任务"];
    }

    
    return @"";
}
@end
