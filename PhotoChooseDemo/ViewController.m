//
//  ViewController.m
//  PhotoChooseDemo
//
//  Created by 张一雄 on 16/4/18.
//  Copyright © 2016年 HuaXiong. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)choosePhotos:(UIButton *)sender {
    
    if ([[UIDevice currentDevice].systemVersion intValue] >= 8.0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择读取方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        //本地相册选择
//        UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"本地相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self choosePhoto];
//        }];
//        [alert addAction:albumAction];
//        
//        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self takePhoto];
//        }];
//        [alert addAction:photoAction];
//        
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            
//        }];
//        [alert addAction:cancelAction];
//        
//        
//        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择读取方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"本地相册",@"拍照", nil];
        [sheet showInView:self.view];
        
        NSLog(@"======%d",sheet.subviews.count);
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self choosePhoto];
    } else if (buttonIndex == 1) {
        [self takePhoto];
    }
}

//相册选择
- (void)choosePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

//拍照
- (void)takePhoto {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        NSLog(@"你的设备不支持拍照功能");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"=========%@",info);
        //进行界面显示
        _imageView.image = image;
        
//        //本地存储
//        [self saveThePhoto:image];
        
        //上传图片
        [self upLoadImageWithImage:image];
    }];
}

//存储图片
- (void)saveThePhoto:(UIImage *)img {
    //获取沙盒路径
    NSString *path_sandox = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imagePath = [path_sandox stringByAppendingString:@"/Documents/myImage.png"];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(img) writeToFile:imagePath atomically:YES];
}

//上传图片  使用AFNetworking
- (void)upLoadImageWithImage:(UIImage *)image {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //将图片转化为进制流
//    此处转为jpg格式图片
    NSData *data=UIImageJPEGRepresentation(image, .5);
//    此处转为png格式图片
//    NSData *data = UIImagePNGRepresentation(image);
    
//    注：   以上两个转化为data类型的数据方法  选择其一就行
    
    /*以下注意
     *url为你上传后台对应的url
     *parameters  如果需要参数 则传
    */
    
    NSDictionary *dict = @{
                           @"user_id":@"29",
                           @"pic":data
                           };
    
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:@"http://123.57.142.103/api/login/pic_edit" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFormData:data name:@"image"];
        [formData appendPartWithFileData:data name:@"file" fileName:@"aaaa.png" mimeType:@"image/jpg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
//        NSLog(@"--------%s",[responseObject bytes]);
        
        NSLog(@"=========%@",responseObject[@"errmsg"]);
        
        //在此处写上传成功之后的代码
        NSLog(@"图片上传成功");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"----------%@",error.localizedFailureReason
              );
       NSLog(@"图片上传失败");
    }];

}

@end
