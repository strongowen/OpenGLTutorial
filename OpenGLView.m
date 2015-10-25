//
//  OpenGLView.m
//  Tutorial01
//
//  Created by 张全伟 on 15/10/25.
//  Copyright © 2015年 张全伟. All rights reserved.
//

#import "OpenGLView.h"

@interface OpenGLView()

- (void)setupLayer;

@end


@implementation OpenGLView


+ (Class)layerClass{
    //只有CAEAGLLayer类型的layer才支持OpenGL绘图.
    return [CAEAGLLayer class];//动态修改返回类类型
}


#pragma - mark layer的配置
//默认的 CALayer 是透明的，我们需要将它设置为 opaque 才能看到在它上面描绘的东西。
- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*)self.layer;
    
    _eaglLayer.opaque = YES;//设置为不透明

    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8.我们设置 kEAGLDrawablePropertyRetainedBacking 为NO，表示不想保持呈现的内容，因此在下一次呈现时，应用程序必须完全重绘一次。将该设置为YES对性能和资源影像较大，因此只有当renderbuffer需要保持其内容不变时才为YES。
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
}

#pragma - mark 创建、设置与OpenGL ES相关的东西
//创建OpenGL渲染的上下文
- (void)setupContext
{
    //指定OpenGL渲染API的版本-version2
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    
    if (!_context) {
        NSLog(@"Failed to initialize OpenGL 2.0 Context");
        exit(1);
    }
    
    //设置为当前上下文，返回成功或失败的标记
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current context");
        exit(1);
    }
}


#pragma 创建renderBuffer
- (void)setupRenderBuffer{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    
    //为color renderBuffer分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
}

/**
 *  glGenRenderbuffers
 *  原型是 void glGenRenderbuffers (GLsizei n, GLuint* renderbuffers),它是位renderbuffer申请一个id。n表示申请的buffer的个数，renderbuffers返回分配的id。id不为0，0为OpenGL保留值，我们也不能使用0作为id。
 *
 */

/**
 *  glBindRenderbuffer
 *  将指定的id设置为当前的renderbuffer。参数target必须为GL_RENDERBUFFER。当第一次被设置时，会初始化renderbuffer对象，初始值为：
 *  width & height:默认值为0；   internal format：内部格式，三大buffer格式之一。另外两个是，color，depth or stencil； Color bit-depth：仅当内部格式为color时，设置颜色的bit-depth，默认值为0;     Depth bit-depth:同上；    Stencil bit-depth:同上
 */

/**
 *  函数- (BOOL)renderbufferStorage...
 *  在内部使用drawable（在这里是EAGLayer）的相关信息作为参数调用了bufferStorage；bufferStorage指定存储在buffer中图像的宽高和颜色等格式，并按照此规格为之分配存储空间。
 *
 */
#pragma 创建framebuffer object
- (void)setupFrameBuffer{
    glGenRenderbuffers(1, &_frameBuffer);
    //设置为当前的framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    //将_colorRenderBuffer装配到 GL_COLOR_ATTACHMENT 0 这个装配点上。
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

/**
 *  函数原型为void glFramebufferRenderbuffer(GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer)
 *  将相关buffer(三大buffer之一) attach到framebuffer上，或从framebuffer上detach。参数attachment是指定renderbuffer被装配到哪个装配点上，其值是GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT中的一个，分别对应 color，depth和 stencil三大buffer。
 *
 */

#pragma 当UIView布局发生变化时，由于layer变化，导致renderbuffer不再相符，需要销毁现有的renderbuffer和framebuffer。
- (void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
    
}

#pragma - mark 渲染点东西看看
- (void)render
{
    //设置清屏颜色，默认是黑色
    glClearColor(0, 1.0, 0, 1.0);
    //指定要用清屏颜色清除的buffer（由mask指定的，mask 可以是 GL_COLOR_BUFFER_BIT，GL_DEPTH_BUFFER_BIT和GL_STENCIL_BUFFER_BIT的自由组合），在这里只用到了color buffer。
    glClear(GL_COLOR_BUFFER_BIT);
    
    //将指定的buffer呈现在屏幕上（前面已经绑定为当前 renderbuffer 的那个）。
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)layoutSubviews{
    [self setupLayer];
    [self setupContext];
    
    [self destoryRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    
    [self render];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
