//
//  AVCaptureDevice+FrontCamera.m
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 29/05/14.
//
//

#import "AVCaptureDevice+FrontCamera.h"

@implementation AVCaptureDevice (FrontCamera)
+ (AVCaptureDevice *)frontFacingCameraIfAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return captureDevice;
}
@end
