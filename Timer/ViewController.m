//
//  ViewController.m
//  Timer
//
//  Created by tongle on 2017/3/15.
//  Copyright © 2017年 tongle. All rights reserved.
//

#import "ViewController.h"
#import "StellarTimeView.h"

#define WIN_WIDTH  [self.view.bounds.size.width]
#define WIN_HEIGHT [self.view.bounds.size.height]
#define BACKCOLOR  [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1]
#define BARCOLOR  [QPUtilities colorWithHexString:@"#242947" alpha:1.f]

@interface ViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    BOOL OpenOrClose;
    dispatch_source_t _timer;
    int hours;
    int minites;
    int secondTotal;
    int delayTotal;
}
@property (nonatomic, strong)UIView * dateView;
@property (nonatomic, strong)UIPickerView * datePickerView;
@property (nonatomic, strong)StellarTimeView * dateTimeView;
@property (nonatomic, strong)UIButton * cancelBtn;
@property (nonatomic, strong)UIButton * openBtn;
@property (nonatomic, strong)UIButton * closeBtn;
@property (nonatomic, strong)NSArray * hourArray;
@property (nonatomic, strong)NSArray * minuteArray;


@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKCOLOR;
    [self setNavigationbar];

    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, 50)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    


    
    [self.dateView addSubview:self.dateTimeView];
    [self.dateView addSubview:self.datePickerView];
    [self.view addSubview:self.dateView];
    [self.view addSubview:self.cancelBtn];
    [self.view addSubview:self.openBtn];
    [self.view addSubview:self.closeBtn];
    NSArray * btnArray = @[self.openBtn,self.closeBtn];
    for (UIButton * btn in btnArray) {
        if (btn.tag == 120) {
            [btn setTitle:@"open" forState:UIControlStateNormal];
        }else{
            [btn setTitle:@"close" forState:UIControlStateNormal];
        }
        [btn addTarget:self action:@selector(OpenAndCloseTouch:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"icon-time-on"] forState:UIControlStateNormal];
        [btn setFont:[UIFont fontWithName:@"Arial" size:16]];
    }
    // 退出APP，执行通知，让定时器继续走动
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(timeHeadle) name:@"time" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(APPDismiss) name:@"dismiss" object:nil];
    
    _hourArray = [[NSArray alloc]initWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",nil];
    _minuteArray = [[NSArray alloc]initWithObjects:@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59",nil];
}
- (void)setNavigationbar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 44)];
    navigationBar.tintColor = [UIColor blackColor];
    navigationBar.backgroundColor = [UIColor greenColor];
    //创建UINavigationItem
    UINavigationItem * navigationBarTitle = [[UINavigationItem alloc] initWithTitle:@"UINavigationBar"];
    [navigationBar pushNavigationItem: navigationBarTitle animated:YES];
    [self.view addSubview: navigationBar];

}
-(int)isTotalTimeSelect{
    return [[[NSUserDefaults standardUserDefaults]objectForKey:@"isTotalTime"] intValue];
}
-(void)setIsTotalTimeSelect:(int)isTotalTimeSelect{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:isTotalTimeSelect] forKey:@"isTotalTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)APPDismiss{
    _timer = nil;
    [self timeHeadle];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_timer) {
        dispatch_cancel(_timer);
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self timeHide];
}
- (void)timeHeadle{
    NSLog(@"_timer ------%@",_timer);
    
    if (_timer==nil) {
        __block int timeout; //倒计时时间
        
        if (self.datePickerView.isHidden == NO) {
            timeout = secondTotal;
            [self setIsTotalTimeSelect:secondTotal];
            
        }else{
           
        }
        NSLog(@"timeout----%d",timeout);
        
        if (timeout!=0) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
            dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),(uint64_t) 1.0 * NSEC_PER_SEC, 0); //每秒执行
            dispatch_source_set_event_handler(_timer, ^{
                if(timeout<=0){ //倒计时结束，关闭
                    dispatch_source_cancel(_timer);
                    _timer = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self timeHide];
                    });
                }else{
                    int hour = (int)(timeout/3600);
                    int minute = (int)(timeout-hour*3600)/60;
                    int second = timeout-hour*3600-minute*60;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (secondTotal == 0) {
                            int  total =[self isTotalTimeSelect];
                            self.dateTimeView.percent = (CGFloat)(total-delayTotal) / total + (CGFloat)(delayTotal- timeout) / total;
                        }else{
                            self.dateTimeView.percent = (CGFloat)(secondTotal-timeout)/(CGFloat)secondTotal;
                        }
                        if (hour<10) {
                            if (minute<10) {
                                if (second<10) {
                                    self.dateTimeView.progressView.text = [NSString stringWithFormat:@"0%d:0%d:0%d",hour,minute,second];
                                }else{
                                    self.dateTimeView.progressView.text = [NSString stringWithFormat:@"0%d:0%d:%d",hour,minute,second];
                                }
                            }else {
                                if (second<10) {
                                    self.dateTimeView.progressView.text = [NSString stringWithFormat:@"0%d:%d:0%d",hour,minute,second];
                                }else{
                                    self.dateTimeView.progressView.text = [NSString stringWithFormat:@"0%d:%d:%d",hour,minute,second];
                                }
                            }
                        }else{
                            if (minute<10) {
                                if (second<10) {
                                    self.dateTimeView.progressView.text = [NSString stringWithFormat:@"0%d:0%d:0%d",hour,minute,second];
                                }else{
                                    self.dateTimeView.progressView.text = [NSString stringWithFormat:@"0%d:0%d:%d",hour,minute,second];
                                }
                            }else {
                                if (second<10) {
                                    self.dateTimeView.progressView.text = [NSString stringWithFormat:@"0%d:%d:0%d",hour,minute,second];
                                }else{
                                    self.dateTimeView.progressView.text = [NSString stringWithFormat:@"0%d:%d:%d",hour,minute,second];
                                }
                            }
                        }
                    });
                    timeout--;
                }
            });
            dispatch_resume(_timer);
        }else{
            self.dateTimeView.progressView.text = [NSString stringWithFormat:@"00:00:00"];
        }
    }
}


-(UIPickerView *)datePickerView{
    if (_datePickerView == nil) {
        _datePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, self.dateView.frame.size.width, self.view.bounds.size.height / 2 -100)];
        _datePickerView.delegate = self;
        _datePickerView.dataSource = self;
        _datePickerView.showsSelectionIndicator = YES;
    }
    return _datePickerView;
}
-(StellarTimeView *)dateTimeView{
    if (_dateTimeView == nil) {
        _dateTimeView =[[StellarTimeView alloc]initWithFrame:CGRectMake(0, 40, self.dateView.frame.size.width, self.view.bounds.size.height / 2 - 100)];
    }
    return _dateTimeView;
}
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
#pragma unused(pickerView)
    return 3;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
#pragma unused(pickerView)
    if (component == 0) {
        return (unsigned)[_hourArray count];
    }else if (component == 1){
        return 1;
    }else
        return (unsigned)[_minuteArray count];
}
#pragma mark -- UIPickerViewDelegate
// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
#pragma unused(pickerView,component)
    return 60;
}
- (CGSize)rowSizeForComponent:(NSInteger)component{
#pragma unused(component)
    
    CGSize  size = CGSizeFromString(@"20");
    return  size;
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
#pragma unused(pickerView)
    if (component == 0) {
        NSString  *_proNameStr = [_hourArray objectAtIndex:(unsigned)row];
        hours = [_proNameStr intValue];
    }else if (component == 1){
        
    }
    else {
        NSString  *_proTimeStr = [_minuteArray objectAtIndex:(unsigned)row];
        minites = [_proTimeStr intValue];
    }
    
}
//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
#pragma unused(pickerView)
    if (component == 0) {
        return [_hourArray objectAtIndex:(unsigned)row];
    }else if (component == 1){
        return @":";
    }
    else {
        return [_minuteArray objectAtIndex:(unsigned)row];
        
    }
}
-(void)OpenAndCloseTouch:(UIButton *)sender{
    
    self.cancelBtn.enabled = YES;
    if (sender.tag == 120) {
        [self open];
        OpenOrClose = YES;
    }else{
        [self close];
        OpenOrClose = NO;
    }
}
-(void)open{
    [_openBtn setBackgroundImage:[UIImage imageNamed:@"icon-time-off"] forState:UIControlStateNormal];
    [_closeBtn setBackgroundImage:[UIImage imageNamed:@"icon-time-on"] forState:UIControlStateNormal];
}
-(void)close{
    [_closeBtn setBackgroundImage:[UIImage imageNamed:@"icon-time-off"] forState:UIControlStateNormal];
    [_openBtn setBackgroundImage:[UIImage imageNamed:@"icon-time-on"] forState:UIControlStateNormal];
}
-(UIView *)dateView{
    if (_dateView ==nil) {
        _dateView = [[UIView alloc]initWithFrame:CGRectMake(40, 40, self.view.bounds.size.width-80, self.view.bounds.size.height / 2)];
        _dateView.backgroundColor = [UIColor whiteColor];
        _dateView.layer.cornerRadius = 5;
        _dateView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        _dateView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        _dateView.layer.shadowOpacity = 0.3f;
    }
    return _dateView;
}
-(UIButton *)openBtn{
    if (_openBtn == nil) {
        _openBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 115, self.view.bounds.size.height / 2 + 15, 60, 60)];
        [_openBtn setTag:120];
    }
    return _openBtn;
}
-(UIButton *)closeBtn{
    if (_closeBtn == nil) {
        _closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width / 2 + 65, self.view.bounds.size.height / 2 + 15, 60, 60)];
        [_closeBtn setTag:121];
    }
    return _closeBtn;
}
-(UIButton *)cancelBtn{
    if (_cancelBtn == nil) {
        _cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 74, self.view.bounds.size.height / 2 + 110, 148, 36)];
        [_cancelBtn setBackgroundColor:[UIColor greenColor]];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelBtn.layer.cornerRadius = 5;
        _cancelBtn.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        _cancelBtn.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        _cancelBtn.layer.shadowOpacity = 0.3f;
        [_cancelBtn setFont:[UIFont fontWithName:@"Arial" size:16]];
        [_cancelBtn addTarget:self action:@selector(startOrCancel:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.enabled = NO;
        
    }
    return _cancelBtn;
}
-(void)pickerHide{
    self.datePickerView.hidden = YES;
    self.dateTimeView.hidden = NO;
    self.cancelBtn.selected = YES;
    self.openBtn.enabled = NO;
    self.closeBtn.enabled = NO;
    self.cancelBtn.enabled = YES;
    [self.cancelBtn setTitle:@"cancel" forState:UIControlStateNormal];
}
-(void)timeHide{
    self.datePickerView.hidden = NO;
    self.dateTimeView.hidden = YES;
    self.cancelBtn.selected = NO;
    self.openBtn.enabled = YES;
    self.closeBtn.enabled = YES;
    [self.cancelBtn setTitle:@"start" forState:UIControlStateNormal];
}
-(void)startOrCancel:(UIButton *)sender{
    if (sender.selected == YES) {
        [self timeHide];
        self.cancelBtn.enabled = NO;
        if (OpenOrClose) {
           
        }else{
           
        }
        if (_timer) {
            dispatch_cancel(_timer);
            _timer = nil;
        }
        
    }else{
        
        _timer = nil;
        NSLog(@"hours-----%d,minites-------%d",hours,minites);
        
        
        if (hours==0 && minites == 0) {
            secondTotal = 60;
        }else{
            secondTotal = hours * 3600 + minites *60;
        }
        [self timeHeadle];
        
        [self pickerHide];
        if (OpenOrClose == YES) {
           
        }else{
           
        }
    }
    
}


-(void)dissmissViewController{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //    [self dissmissViewController];
}
-(void)gotoSettingViewController{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


