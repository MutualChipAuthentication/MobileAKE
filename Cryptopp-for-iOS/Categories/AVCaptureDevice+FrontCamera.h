//
//  AVCaptureDevice+FrontCamera.h
//  Cryptopp-for-iOS
//
//  Created by Paweł Nużka on 29/05/14.
//
//

#import <AVFoundation/AVFoundation.h>

@interface AVCaptureDevice (FrontCamera)
+ (AVCaptureDevice *)frontFacingCameraIfAvailable;

@end
