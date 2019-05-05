//
//  ViewController.m
//  test
//
//  Created by 彭倩倩 on 2019/5/5.
//  Copyright © 2019 pengqianqian. All rights reserved.
//

#import "ViewController.h"
#import "test-Bridging-Header.h"
#import "Masonry.h"
#import "DateValueFormatter.h"
#import "test-Swift.h"

@interface CubicLineSampleFillFormatter : NSObject <IChartFillFormatter>
{
}
@end

@implementation CubicLineSampleFillFormatter

- (CGFloat)getFillLinePositionWithDataSet:(LineChartDataSet *)dataSet dataProvider:(id<LineChartDataProvider>)dataProvider
{
    return -10.f;
}

@end

@interface ViewController ()<ChartViewDelegate>

@property (nonatomic, strong) LineChartView *lineChartView;
@property (nonatomic, strong) LineChartData *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:230/255.0f green:253/255.0f blue:253/255.0f alpha:1];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"折线图";
    titleLabel.font = [UIFont systemFontOfSize:35];
    titleLabel.textColor = [UIColor blueColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(250, 50));
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(self.view).offset(-200);
    }];
    
    UIButton *displayButton = [[UIButton alloc] init];
    [displayButton setTitle:@"重新绘制" forState:UIControlStateNormal];
    [displayButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    displayButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:displayButton];
    [displayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 50));
        make.centerX.mas_equalTo(titleLabel);
        make.centerY.mas_equalTo(self.view).offset(240);
    }];
    [displayButton addTarget:self action:@selector(updateData) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加LineChartView
    self.lineChartView = [[LineChartView alloc] init];
    self.lineChartView.delegate = self;//设置代理
    [self.view addSubview:self.lineChartView];
    [self.lineChartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width-20, 300));
        make.center.mas_equalTo(self.view);
    }];
    
    // 基本样式
    self.lineChartView.backgroundColor =  [UIColor colorWithRed:230/255.0f green:253/255.0f blue:253/255.0f alpha:1];
    self.lineChartView.noDataText = @"暂无数据";
    // 交互样式
    self.lineChartView.scaleYEnabled = NO; // 取消Y轴缩放
    self.lineChartView.scaleXEnabled = NO; // 取消X轴缩放
    self.lineChartView.pinchZoomEnabled = NO; // 取消XY轴同时缩放
    self.lineChartView.doubleTapToZoomEnabled = NO; // 取消双击缩放
    self.lineChartView.legend.enabled = NO;// 不显示图例说明
    self.lineChartView.dragEnabled = YES; // 启用拖拽图表
    self.lineChartView.dragDecelerationEnabled = YES; // 拖拽后是否有惯性效果
    self.lineChartView.dragDecelerationFrictionCoef = 0.9; // 拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
    // X轴样式
    ChartXAxis *xAxis = self.lineChartView.xAxis;
    xAxis.axisLineWidth = 1.0; // 设置X轴线宽
    xAxis.labelPosition = XAxisLabelPositionBottom; // X轴的显示位置，默认是显示在上面的
    xAxis.drawGridLinesEnabled = NO; // 不绘制网格线
    xAxis.labelTextColor = [self colorWithHexString:@"#057748"];//label文字颜色
    DateValueFormatter *valueFormatter = [[DateValueFormatter alloc] init];//坐标数值样式
    xAxis.valueFormatter = valueFormatter;
    
    // Y轴样式
    self.lineChartView.rightAxis.enabled = NO;//不绘制右边轴
    ChartYAxis *leftAxis = self.lineChartView.leftAxis;//获取左边Y轴
    leftAxis.labelCount = 2; // Y轴label数量，数值不一定，如果forceLabelsEnabled等于YES, 则强制绘制制定数量的label, 但是可能不平均
    leftAxis.forceLabelsEnabled = NO; // 不强制绘制指定数量的label
    leftAxis.axisMinimum = 0; // 设置Y轴的最小值
    leftAxis.drawZeroLineEnabled = YES;
    leftAxis.axisMaximum = 120; // 设置Y轴的最大值
    leftAxis.inverted = NO; // 是否将Y轴进行上下翻转
    leftAxis.axisLineWidth = 1.0/[UIScreen mainScreen].scale; // Y轴线宽
    leftAxis.axisLineColor = [UIColor blackColor]; // Y轴颜色
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart; // label位置
    leftAxis.labelTextColor = [self colorWithHexString:@"#057748"]; // 文字颜色
    leftAxis.labelFont = [UIFont systemFontOfSize:10.0f]; // 文字字体
    leftAxis.gridLineDashLengths = @[@3.0f, @3.0f]; // 设置虚线样式的网格线
    leftAxis.gridColor = [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1]; // 网格线颜色
    leftAxis.gridAntialiasEnabled = YES; // 开启抗锯齿
    // 添加限制线
    ChartLimitLine *limitLine = [[ChartLimitLine alloc] initWithLimit:100 label:@""];
    limitLine.lineWidth = 1;
    limitLine.lineColor = [self colorWithHexString:@"#c83c23"]; // 限制线颜色
    limitLine.lineDashLengths = @[@5.0f, @5.0f]; // 虚线样式
    limitLine.labelPosition = ChartLimitLabelPositionTopRight; // 位置
//    limitLine.valueTextColor = [self colorWithHexString:@"#057748"];//label文字颜色
//    limitLine.valueFont = [UIFont systemFontOfSize:12];//label字体
    [leftAxis addLimitLine:limitLine];//添加到Y轴上
    leftAxis.drawLimitLinesBehindDataEnabled = YES;//设置限制线绘制在折线图的后面
    //描述及图例样式
    ChartDescription *description = [[ChartDescription alloc] init];
    description.text = @"折线图";
    description.textColor = [UIColor darkGrayColor];
    [self.lineChartView setChartDescription:description];
    self.lineChartView.legend.form = ChartLegendFormLine;
    self.lineChartView.legend.formSize = 30;
    self.lineChartView.legend.textColor = [UIColor darkGrayColor];
    
    // 显示气泡效果
    BalloonMarker *marker = [[BalloonMarker alloc]
                             initWithColor: [UIColor colorWithWhite:0/255. alpha:0.7]
                             font: [UIFont boldSystemFontOfSize:10.0]
                             textColor: UIColor.whiteColor
                             insets: UIEdgeInsetsMake(2, 0, 0, 0)];
    marker.chartView = _lineChartView;
    marker.arrowSize = CGSizeMake(10, 10);
//    marker.color = [UIColor greenColor];
    marker.minimumSize = CGSizeMake(40, 30);
    marker.chartView = _lineChartView;
    _lineChartView.marker = marker;
    
    [self updateData];
}

- (void)updateData {
    [self setData];
    [self.lineChartView animateWithXAxisDuration:1];
}

- (void)setData {
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    
    int count = 11;//X轴上要显示多少条数据
    double range = 50;//Y轴的值

    for (int i = 8; i < 8+count; i++) {
        double mult = (range + 1);
        double val = (double) (arc4random_uniform(mult)) + 20;
        [yVals1 addObject:[[ChartDataEntry alloc] initWithX:i y:val]];
    }
    
    LineChartDataSet *set1 = nil;
    if (_lineChartView.data.dataSetCount > 0) {
        set1 = (LineChartDataSet *)_lineChartView.data.dataSets[0];
        [set1 replaceEntries:yVals1];
        [_lineChartView.data notifyDataChanged];
        [_lineChartView notifyDataSetChanged];
    } else {
        set1 = [[LineChartDataSet alloc] initWithEntries:yVals1 label:@"lineName"];
        // 曲线模式
        set1.mode = LineChartModeCubicBezier;
        set1.cubicIntensity = 0.2; // 曲线弧度
        set1.lineWidth = 1.0;
        set1.circleRadius = 4.0;
        
        // 拐点
        set1.drawCirclesEnabled = NO; // 是否绘制拐点
        set1.drawValuesEnabled = NO;//是否在拐点处显示数据
        set1.drawCircleHoleEnabled = YES;//是否绘制中间的空心
        set1.circleHoleRadius = 2.0f;//空心的半径
        set1.circleHoleColor = [UIColor blackColor];//空心的颜色
        [set1 setCircleColor:UIColor.yellowColor];
        set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        
        //  单纯的颜色填充
//        [set1 setColor:UIColor.redColor];
//        set1.fillColor = UIColor.blueColor;
//        set1.fillAlpha = 0.1;
//        set1.drawFilledEnabled = YES;
        
        // 渐变色颜色填充
        set1.drawFilledEnabled = YES;//是否填充颜色
        NSArray *gradientColors = @[(id)[ChartColorTemplates colorFromString:@"#FFFFFFFF"].CGColor,
                                    (id)[ChartColorTemplates colorFromString:@"#FF007FFF"].CGColor];
        CGGradientRef gradientRef = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
        set1.fillAlpha = 0.8f; //透明度
        set1.fill = [ChartFill fillWithLinearGradient:gradientRef angle:90.0f]; //赋值填充颜色对象
        CGGradientRelease(gradientRef); // 释放gradientRef
        
        // 点击选中拐点的交互样式
        set1.highlightEnabled = YES; // 选中拐点,是否开启高亮效果(显示十字线)
        set1.highlightColor = [self colorWithHexString:@"#c83c23"];//点击选中拐点的十字线的颜色
        set1.highlightLineWidth = 1.0;//十字线宽度
        set1.highlightLineDashLengths = @[@5, @5];//十字线的虚线样式

        set1.drawHorizontalHighlightIndicatorEnabled = NO;
        set1.fillFormatter = [[CubicLineSampleFillFormatter alloc] init];
        
        LineChartData *data = [[LineChartData alloc] initWithDataSet:set1];
        [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:9.f]];
        [data setDrawValues:NO];
        _lineChartView.data = data;
    }
}

#pragma mark - ChartViewDelegate
// 点击选中折线拐点时回调
- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * _Nonnull)highlight{

}

// 没有选中折线拐点时回调
- (void)chartValueNothingSelected:(ChartViewBase * _Nonnull)chartView{
    NSLog(@"---chartValueNothingSelected---");
}

// 放大折线图时回调
- (void)chartScaled:(ChartViewBase * _Nonnull)chartView scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY{
    NSLog(@"---chartScaled---scaleX:%g, scaleY:%g", scaleX, scaleY);
}

// 拖拽折线图时回调
- (void)chartTranslated:(ChartViewBase * _Nonnull)chartView dX:(CGFloat)dX dY:(CGFloat)dY{
    NSLog(@"---chartTranslated---dX:%g, dY:%g", dX, dY);
}

// 将十六进制颜色转换为 UIColor 对象
- (UIColor *)colorWithHexString:(NSString *)color{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // strip "0X" or "#" if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

@end
