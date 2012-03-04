//
//  NBGraphicsSequence.m
//  Desktop Ponies
//
//  Created by Sean Cross on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NBGraphicsSequence.h"
#import "gif_lib.h"

struct pixel {
    unsigned char r, g, b, a;
} __attribute__ ((__packed__));

struct image {
    struct pixel *pixels;
    unsigned int delay;
    unsigned int texId;
};

@implementation NBGraphicsSequence


- (id)initWithPath:(NSString *)path {
    GifFileType *gif;
    int currentImage;
    int frameSize;
    
    if (!(self = [super init]))
        return nil;
    
    /* Attempt to load the file */
    gif = DGifOpenFileName([path UTF8String]);
    if (!gif) {
        [super release];
        return nil;
    }
    
    if (DGifSlurp(gif) != GIF_OK) {
        NSLog(@"Unable to open %@: Error code %d\n", path, GifLastError());
        [super release];
        DGifCloseFile(gif);
        return nil;
    }
    
    totalFrames = gif->ImageCount;
    size = NSMakeSize(gif->SWidth, gif->SHeight);
    frameSize = gif->SWidth * gif->SHeight * sizeof(struct pixel);
    
    data = NSZoneMalloc(NULL, totalFrames * sizeof(struct image));
    
    /* Pre-allocate all pixel data, so we can deal with image disposal methods */
    for (currentImage = 0; currentImage < totalFrames; currentImage++) {
        data[currentImage].pixels = NSZoneMalloc(NULL, frameSize);
        memset(data[currentImage].pixels, 0, frameSize);
    }
    
    for (currentImage = 0; currentImage < totalFrames; currentImage++) {
        ColorMapObject *colorMap;
        SavedImage     *image;
        struct pixel   *pixels;
        struct pixel   *pixel;
        unsigned int    x, y;
        int             bgColorIndex;
        int             colorCount;
        unsigned char  *raster;
        GifColorType   *lut;
        BOOL            interlace;
        int             interlacePass;
        int             interlaceDelta;
        int             block;
        int             width, height, left, top;
        int             dispose;
        
        colorMap        = gif->SColorMap;
        image           = &gif->SavedImages[currentImage];
        width           = image->ImageDesc.Width;
        height          = image->ImageDesc.Height;
        left            = image->ImageDesc.Left;
        top             = image->ImageDesc.Top;
        dispose         = 0;
        pixels          = data[currentImage].pixels;
        bgColorIndex    = (gif->SColorMap==NULL) ? -1 : gif->SBackGroundColor;
        
        if (colorMap) {
            lut         = colorMap->Colors;
            colorCount  = colorMap->ColorCount;
        }
        else {
            lut = NULL;
            colorCount = 0;
        }
        
        if (image->ImageDesc.ColorMap) {
            lut = image->ImageDesc.ColorMap->Colors;
            colorCount = image->ImageDesc.ColorMap->ColorCount;
        }
        
        /* Defalt delay */
        data[currentImage].delay = 0;
        data[currentImage].texId = 0;
        
        for (block = 0; block < image->ExtensionBlockCount; block++) {
            ExtensionBlock *theBlock = image->ExtensionBlocks+block;
            int delay;
            if (theBlock->ByteCount == 4 && theBlock->Function == 0xF9) {
                
                // Unpack the delay
                delay = (0xff00 & theBlock->Bytes[2]<<8) | (0xff & theBlock->Bytes[1]);
                
                // Convert GIF's centiseconds into milliseconds
                data[currentImage].delay = delay*10;
                
                // See if the transparency is different for this frame
                if (theBlock->Bytes[0] & 1)
                    bgColorIndex = 0xff & theBlock->Bytes[3];
                
                // Determine the disposal (inter-frame fade) method
                dispose = (theBlock->Bytes[0] >> 2) & 0x7;
            }
            /*
             else if (theBlock->Function == 0xFE) {
             char d[257];
             bzero(d, sizeof(d));
             memcpy(d, theBlock->Bytes, (theBlock->ByteCount<256?theBlock->ByteCount:256));
             NSLog(@"Found comment on frame %d: %s\n", currentImage, d);
             }
             
             else if (theBlock->Function == 0xFF) {
             char name[9];
             bzero(name, sizeof(name));
             memcpy(name, theBlock->Bytes, 8);
             NSLog(@"Found application data on frame %d for %s\n", currentImage, name);
             }
             
             else {
             NSLog(@"Found a block in image %d function %02x size %d:   %02x %02x %02x %02x\n",
             currentImage, theBlock->Function, theBlock->ByteCount,
             theBlock->Bytes[0], theBlock->Bytes[1],
             theBlock->Bytes[2], theBlock->Bytes[3]);
             continue;
             }
             */
        }
        
        raster          = image->RasterBits;
        interlace       = image->ImageDesc.Interlace;
        interlacePass   = 1;
        interlaceDelta  = 8;

        for (y=top; y<top+height; y++) {
            pixel = &pixels[(y*gif->SWidth)+left];
            for (x=left; x<left+width; x++) {
                unsigned char colorIndex = *raster;
                
                if(colorIndex == bgColorIndex) {
                    /*
                    pixel->a = 255;
                    pixel->r = 255;
                    pixel->g = 0;
                    pixel->b = 255;
                    */
                }
                else if(colorIndex < colorCount) {
                    GifColorType *gifColor = lut+colorIndex;
                    
                    pixel->a = 255;
                    pixel->r = gifColor->Red;
                    pixel->g = gifColor->Green;
                    pixel->b = gifColor->Blue;
                }
                else {
                    pixel->a = 255;
                    pixel->r = 0;
                    pixel->g = 255;
                    pixel->b = 0;
                }
                pixel++;
                raster++;
            }
            
            if(interlace) {
                pixel += (interlaceDelta-1)*width;
                if(pixel >= pixels+width*height){
                    interlacePass++;
                    
                    switch(interlacePass){
                        case 2:
                            pixel = pixels+width*4;
                            interlaceDelta = 8;
                            break;
                        case 3:
                            pixel = pixels+width*2;
                            interlaceDelta = 4;
                            break;
                        case 4:
                            pixel = pixels+width*1;
                            interlaceDelta = 2;
                            break;
                    }
                }
            }
            
        }
        
        /* Now an RGBA image is stored in *pixels */
        data[currentImage].pixels = pixels;
        
        
        
        /* asis disposal (normally disposal type 1, but assume it for now) */
        if (/*dispose == 1 &&*/ currentImage+1 < totalFrames) {
            memcpy(data[currentImage+1].pixels, pixels, frameSize);
        }
        
        if (dispose == 2 && currentImage+1 < totalFrames) {
            for (y=top; y<top+height; y++) {
                pixel = &data[currentImage+1].pixels[(y*gif->SWidth)+left];
                for (x=left; x<left+width; x++) {
                    pixel->r = 0;
                    pixel->g = 0;
                    pixel->b = 0;
                    pixel->a = 0;
                    pixel++;
                }
            }
        }
        /* background disposal */
        /*
        if (dispose == 2 && currentImage+1 < totalFrames) {
            memset(data[currentImage+1].pixels, 0, frameSize);
        }
         */
        
        /* previous frame disposal */
        else if (dispose == 3 && currentImage > 0 && currentImage+1 < totalFrames) {
            memcpy(data[currentImage+1].pixels, data[currentImage-1].pixels, frameSize);
        }

    }
    
    DGifCloseFile(gif);
    
    return self;
}

- (int)totalFrames {
    return totalFrames;
}

- (void *)dataForFrame:(int)frame {
    return data[frame].pixels;
}

- (int)width {
    return size.width;
}

- (int)height {
    return size.height;
}

- (NSSize)size {
    return size;
}

- (unsigned int)textureIdForFrame:(int)frame {
    return data[frame].texId;
}

- (void)setTextureId:(unsigned int)tex forFrame:(int)frame
{
    data[frame].texId = tex;
}

- (int)delayForFrame:(int)frame {
    return data[frame].delay;
}

@end
