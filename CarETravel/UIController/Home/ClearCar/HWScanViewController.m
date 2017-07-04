//
//  HWScanViewController.m
//  HWScanTest
//
//  Created by sxmaps_w on 2017/2/18.
//  Copyright © 2017年 hero_wqb. All rights reserved.
//

#import "HWScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "RvcNetWork.h"
#import "Config.h"
#import "UIWaitView.h"
#import "UICode.h"

#define KMainW [UIScreen mainScreen].bounds.size.width
#define KMainH [UIScreen mainScreen].bounds.size.height

@interface HWScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,NetSocketDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, weak) UIImageView *line;
@property (nonatomic, assign) NSInteger distance;

@end

@implementation HWScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem * leftBackBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_left"] style:UIBarButtonItemStylePlain target:self action:@selector(backCodeAction)];
    self.navigationItem.leftBarButtonItem = leftBackBarItem;
    
    [RvcNetWork shared].response = self;

    //初始化信息
    [self initInfo];
    
    //创建控件
    [self creatControl];
    
    //设置参数
    [self setupCamera];
    
    //添加定时器
    [self addTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopScanning];
}

- (void)backCodeAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initInfo
{
    //背景色
    self.view.backgroundColor = [UIColor blackColor];
    
    //导航标题
    self.navigationItem.title = @"二维码/条形码";
    
    //导航右侧相册按钮
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(photoBtnOnClick)];
}

- (void)creatControl
{
    CGFloat scanW = KMainW * 0.65;
    CGFloat padding = 10.0f;
    CGFloat labelH = 20.0f;
    CGFloat tabBarH = 64.0f;
    CGFloat cornerW = 26.0f;
    CGFloat marginX = (KMainW - scanW) * 0.5;
    CGFloat marginY = (KMainH - scanW - padding - labelH) * 0.5;
    
    //遮盖视图
    for (int i = 0; i < 4; i++) {
        UIView *cover = [[UIView alloc] initWithFrame:CGRectMake(0, (marginY + scanW) * i, KMainW, marginY + (padding + labelH) * i)];
        if (i == 2 || i == 3) {
            cover.frame = CGRectMake((marginX + scanW) * (i - 2), marginY, marginX, scanW);
        }
        cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self.view addSubview:cover];
    }
    
    //扫描视图
    UIView *scanView = [[UIView alloc] initWithFrame:CGRectMake(marginX, marginY, scanW, scanW)];
    [self.view addSubview:scanView];
    
    //扫描线
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scanW, 2)];
    [self drawLineForImageView:line];
    [scanView addSubview:line];
    self.line = line;
    
    //边框
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scanW, scanW)];
    borderView.layer.borderColor = [[UIColor whiteColor] CGColor];
    borderView.layer.borderWidth = 1.0f;
    [scanView addSubview:borderView];
    
    //扫描视图四个角
    for (int i = 0; i < 4; i++) {
        CGFloat imgViewX = (scanW - cornerW) * (i % 2);
        CGFloat imgViewY = (scanW - cornerW) * (i / 2);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgViewX, imgViewY, cornerW, cornerW)];
        if (i == 0 || i == 1) {
            imgView.transform = CGAffineTransformRotate(imgView.transform, M_PI_2 * i);
        }else {
            imgView.transform = CGAffineTransformRotate(imgView.transform, - M_PI_2 * (i - 1));
        }
        [self drawImageForImageView:imgView];
        [scanView addSubview:imgView];
    }
    
    //提示标签
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(scanView.frame) + padding, KMainW, labelH)];
    label.text = @"将二维码/条形码放入框内，即可自动扫描";
    label.font = [UIFont systemFontOfSize:16.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    
    //选项栏
    UIView *tabBarView = [[UIView alloc] initWithFrame:CGRectMake(0, KMainH - tabBarH - 64, KMainW, tabBarH)];
    tabBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    [self.view addSubview:tabBarView];
    
    //开启照明按钮
    UIButton *lightBtn = [[UIButton alloc] initWithFrame:CGRectMake(KMainW - 100, 0, 100, tabBarH)];
    lightBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [lightBtn setTitle:@"开启照明" forState:UIControlStateNormal];
    [lightBtn setTitle:@"关闭照明" forState:UIControlStateSelected];
    [lightBtn addTarget:self action:@selector(lightBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [tabBarView addSubview:lightBtn];
}

- (void)setupCamera
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //1、初始化相机设备
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
 
        //2、初始化输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
        
        //3、初始化输出流
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        //4、设置代理，主线程刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        // 设置扫描范围(每一个取值0～1，以屏幕右上角为坐标原点)
        // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）
//        output.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
        
        //5、初始化链接对象
        _session = [[AVCaptureSession alloc] init];
        //高质量采集率
//        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        _session.sessionPreset = AVCaptureSessionPreset1920x1080;
        
        if ([_session canAddInput:input]) [_session addInput:input];
        if ([_session canAddOutput:output]) [_session addOutput:output];
        
        // 6、设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
        // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
//        output.metadataObjectTypes = [NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, nil];
        output.metadataObjectTypes = output.availableMetadataObjectTypes;
        
        //更新界面
        dispatch_async(dispatch_get_main_queue(), ^{
            // 7、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
            _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
            _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
            _preview.frame = CGRectMake(0, 0, KMainW, KMainH);
            
            // 8、将图层插入当前视图
            [self.view.layer insertSublayer:_preview atIndex:0];
            // 9、启动会话
//            [_session startRunning];
            
            //放大焦距
            NSError *error = nil;
            [_device lockForConfiguration:&error];
            if (_device.activeFormat.videoMaxZoomFactor > 2) {
                _device.videoZoomFactor = 2;
            }else{
                _device.videoZoomFactor = _device.activeFormat.videoMaxZoomFactor;
            }
            [_device unlockForConfiguration];
            //开始捕获
            [_session startRunning];
        });
    });
}

- (void)addTimer
{
    _distance = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)timerAction
{
    if (_distance++ > KMainW * 0.65) _distance = 0;
    _line.frame = CGRectMake(0, _distance, KMainW * 0.65, 2);
}

- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
}

//照明按钮点击事件
- (void)lightBtnOnClick:(UIButton *)btn
{
    //判断是否有闪光灯
    if (![_device hasTorch]) {
        [self showAlertWithTitle:@"当前设备没有闪光灯，无法开启照明功能" message:nil sureHandler:nil cancelHandler:nil];
        return;
    }
    
    btn.selected = !btn.selected;
    
    [_device lockForConfiguration:nil];
    if (btn.selected) {
        [_device setTorchMode:AVCaptureTorchModeOn];
    }else {
        [_device setTorchMode:AVCaptureTorchModeOff];
    }
    [_device unlockForConfiguration];
}

//进入相册
- (void)photoBtnOnClick
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.delegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
    }else {
        [self showAlertWithTitle:@"当前设备不支持访问相册" message:nil sureHandler:nil cancelHandler:nil];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //扫描完成
    if ([metadataObjects count] > 0) {
        //停止扫描
        [self stopScanning];
        //显示结果
//        [self showAlertWithTitle:@"扫描结果" message:[[metadataObjects firstObject] stringValue] sureHandler:nil cancelHandler:nil];
        NSLog(@"扫描结果:%@",[[metadataObjects firstObject] stringValue]);
        [[UIWaitView sharedClient] showPopUpView:@"扫码成功" withImage:@"success" complement:^{
            [[RvcNetWork shared] orderBarcodeBindWithLoginID:[UIData sharedClient].loginID withOrderId:_orderid withBarcode:[[metadataObjects firstObject] stringValue] withBindType:1 withSessionSid:[[RvcNetWork shared] nextSessionID]];
        }];
    }
}

- (void)stopScanning
{
    [_session stopRunning];
    _session = nil;
    [_preview removeFromSuperlayer];
    [self removeTimer];
}

- (void)netSocketClient:(id)netSocket withMethod:(int)method didReceivedData:(id)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseOrderBarcodeBind:data];
    });
}

- (void)parseOrderBarcodeBind:(TcpResponse*)response{
    if (kOrderBarcodeBindResponse != response.tag)
    {
        return;
    }
    id data = response.responseData;
    NSString *message = [[UICode sharedClient] messageWithCode:response.retCode];
    if (![kParseRetCodeOK isEqualToString:message]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIWaitView sharedClient] hideLoading];
//            [[UIWaitView sharedClient] showPrompt:message withImage:@"alert.png"];
            [[UIWaitView sharedClient] showPopUpView:message withImage:@"alert.png" complement:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        });
        return;
    }
    
    [[UIWaitView sharedClient] showPopUpView:@"绑定二维码成功" withImage:@"success" complement:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - UIImagePickerControllrDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //获取相册图片
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        //识别图片
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];

        //识别结果
        if (features.count > 0) {
            [self showAlertWithTitle:@"扫描结果" message:[[features firstObject] messageString] sureHandler:nil cancelHandler:nil];
            
        }else{
            [self showAlertWithTitle:@"没有识别到二维码或条形码" message:nil sureHandler:nil cancelHandler:nil];
        }
    }];
}

//提示弹窗
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message sureHandler:(void (^)())sureHandler cancelHandler:(void (^)())cancelHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:sureHandler];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:cancelHandler];
    [alertController addAction:sureAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//绘制角图片
- (void)drawImageForImageView:(UIImageView *)imageView
{
    UIGraphicsBeginImageContext(imageView.bounds.size);

    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线条宽度
    CGContextSetLineWidth(context, 6.0f);
    //设置颜色
    CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
    //路径
    CGContextBeginPath(context);
    //设置起点坐标
    CGContextMoveToPoint(context, 0, imageView.bounds.size.height);
    //设置下一个点坐标
    CGContextAddLineToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, imageView.bounds.size.width, 0);
    //渲染，连接起点和下一个坐标点
    CGContextStrokePath(context);
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

//绘制线图片
- (void)drawLineForImageView:(UIImageView *)imageView
{
    CGSize size = imageView.bounds.size;
    UIGraphicsBeginImageContext(size);

    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //创建一个颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //设置开始颜色
    const CGFloat *startColorComponents = CGColorGetComponents([[UIColor greenColor] CGColor]);
    //设置结束颜色
    const CGFloat *endColorComponents = CGColorGetComponents([[UIColor whiteColor] CGColor]);
    //颜色分量的强度值数组
    CGFloat components[8] = {startColorComponents[0], startColorComponents[1], startColorComponents[2], startColorComponents[3], endColorComponents[0], endColorComponents[1], endColorComponents[2], endColorComponents[3]
    };
    //渐变系数数组
    CGFloat locations[] = {0.0, 1.0};
    //创建渐变对象
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    //绘制渐变
    CGContextDrawRadialGradient(context, gradient, CGPointMake(size.width * 0.5, size.height * 0.5), size.width * 0.25, CGPointMake(size.width * 0.5, size.height * 0.5), size.width * 0.5, kCGGradientDrawsBeforeStartLocation);
    //释放
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end
