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

#define MAXTUTORPAGECOUNT           120

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
    _pageIndex = 0;
    _bTasksDataInited = NO;
    
    [self loadPageData:_pageIndex];
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
    if (reader == nil) {
        return @"";
    }
    
    NSString* text = [[NSString alloc] initWithData:reader encoding:NSUTF8StringEncoding];
    if (text == nil || text.length <= 0) {
        if (text != nil) {
            [text release];
        }
        return @"";
    }
    
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
    OCSafeRelease(_tutorTable);
    OCSafeRelease(_tutorModel);
    OCSafeRelease(_curTask);
    OCSafeRelease(_tasksData);

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

//custom section 
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    int index = self.tutorModel.sectionsData.count + 1;
    UIView *headerViewBottom=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 51)] autorelease];
    
    if (section == 0) {//header section
        UIImageView *backgroudImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 51)] autorelease];
        backgroudImage.image = [UIImage imageNamed:@"home_list_highlight.png"];
        [headerViewBottom addSubview:backgroudImage];
        
        UILabel *Label = [[[UILabel alloc] initWithFrame:CGRectMake(88, 14, 150, 21)] autorelease];
        [Label setBackgroundColor:[UIColor clearColor]];
        [Label setFont:[UIFont systemFontOfSize:18.0]];
        Label.text = self.tutorModel.title;
        
        //Button and Arrow button
        UIButton *lbtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [lbtn setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
        [lbtn setFrame:CGRectMake(20, 5, 50, 40)];
        [lbtn setBackgroundColor:[UIColor clearColor]];
        [lbtn addTarget:self action:@selector(leftMoreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (self.pageIndex <= 0) {
            lbtn.enabled = NO;
        }
        self.prePageBtn = lbtn;
        
        //Button and Arrow button
        UIButton *rbtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [rbtn setImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
        [rbtn setFrame:CGRectMake(250, 5, 50, 40)];
        [rbtn setBackgroundColor:[UIColor clearColor]];
        [rbtn addTarget:self action:@selector(rightMoreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (self.pageIndex >= MAXTUTORPAGECOUNT) {
            rbtn.enabled = NO;
        }
        self.nextPageBtn = rbtn;
        
        //[headerView addSubview:img];
        [headerViewBottom addSubview:lbtn];
        [headerViewBottom addSubview:Label];
        [headerViewBottom addSubview:rbtn];
    }
    else
    { //中间显示名字
        UIImageView *backgroudImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 51)] autorelease];
        backgroudImage.image = [UIImage imageNamed:@"home_list_highlight.png"];
        [headerViewBottom addSubview:backgroudImage];
        
        UILabel *Label = [[[UILabel alloc] initWithFrame:CGRectMake(88, 14, 180, 21)] autorelease];
        [Label setBackgroundColor:[UIColor clearColor]];
        [Label setFont:[UIFont systemFontOfSize:18.0]];
        
        //tab_select.png
        if (section < index)
        {
            SectionModel* model = [self.tutorModel.sectionsData objectAtIndex:section-1];
            if (model) {
                Label.text = model.title;
            }
        }
        else //task section
        {
            Label.text = @"本期任务";
        }
        
        [headerViewBottom addSubview:Label];
    }
    
	return headerViewBottom;
}

-(void)leftMoreBtnClicked:(id)sender{
    NSLog(@"leftMoreBtnClicked");
    BOOL result = [self loadPageData:_pageIndex-1];
    if (result) {
        _pageIndex -= 1;
        if (_pageIndex <= 0) {
            ((UIButton*)sender).enabled = NO;
        }
        if (_pageIndex < MAXTUTORPAGECOUNT && !self.nextPageBtn.isEnabled) {
            self.nextPageBtn.enabled = YES;
        }
        
        [self.tutorTable reloadData];
    }
}


-(void)rightMoreBtnClicked:(id)sender{
    NSLog(@"rightMoreBtnClicked");
    
    BOOL result = [self loadPageData:_pageIndex+1];
    if (result) {
        _pageIndex += 1;
        if (_pageIndex >= MAXTUTORPAGECOUNT) {
            ((UIButton*)sender).enabled = NO;
        }
        if (_pageIndex > 0 && !self.prePageBtn.isEnabled) {
            self.prePageBtn.enabled = YES;
        }
        
        [self.tutorTable reloadData];
    }
}

- (BOOL) loadPageData:(int)pageIndex
{
    
    NSString* string = [self loadFile:[NSString stringWithFormat:@"%d.txt", pageIndex]];
    
    if (string.length <= 0) { //load file fail
        return NO;
    }
    
    NSDictionary* dic = [self toJSONValue:string];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        TutorSectionModel* model = [[TutorSectionModel  alloc] initWithDataDic:dic];
        self.tutorModel = model;
        [model release];
    }
    
    //task
    if ( !_bTasksDataInited) {
        NSString* taskString = [self loadFile:@"task.json"];
        if (taskString.length >= 0) {
            NSString* taskJson = [self toJSONValue:taskString];
            NSArray *taskArr = [taskJson objectForKey:@"task"];
            if (taskArr != nil && [taskArr isKindOfClass:[NSArray class]] && taskArr.count > 0) {
                NSMutableArray* datas = [[NSMutableArray alloc] initWithCapacity:taskArr.count];
                self.tasksData = datas;
                [datas release];
                for (NSDictionary* taskDic in taskArr) {
                    TaskModel* model = [[TaskModel  alloc] initWithDataDic:taskDic];
                    [_tasksData addObject:model];
                    [model release];
                }
            }
            
            _bTasksDataInited = YES;
        }
    }

    
    //cur task
    TaskModel* model = [self.tasksData objectAtIndex:pageIndex];
    if ([model.weekID integerValue] == pageIndex) {
        self.curTask = model;
    }
    return YES;
}

@end
