//
//  OpenGLView.h
//  Tutorial01
//
//  Created by 张全伟 on 15/10/25.
//  Copyright © 2015年 张全伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface OpenGLView : UIView
{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    
}
@end
