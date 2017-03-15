# Timer

## 一、定时器

  dispatch_source_t _timer;
  
// 启动定时器

 dispatch_resume(_timer);

//  取消定时器

 dispatch_cancel(_timer);
 
 _timer = nil;


## 二、绘制外围动画

  self.dateTimeView.percent = (CGFloat)(secondTotal-timeout)/(CGFloat)secondTotal;

## 三、时间选择器
{
  _datePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, self.dateView.frame.size.width, self.view.bounds.size.height / 2 -100)];
  
 _datePickerView.delegate = self;
 
 _datePickerView.dataSource = self;
 
 _datePickerView.showsSelectionIndicator = YES;
 }
