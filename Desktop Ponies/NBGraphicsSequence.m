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
    void *pixels;
    unsigned int delay;
    unsigned int texId;
};

@implementation NBGraphicsSequence


- (id)initWithPath:(NSString *)path {
    GifFileType *gif;
    int currentImage;
    
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
    currentFrame = 0;
    
    data = NSZoneMalloc(NULL, totalFrames * sizeof(struct image));
    
    for (currentImage = 0; currentImage < totalFrames; currentImage++) {
        ColorMapObject *colorMap;
        SavedImage     *image;
        void           *pixels;
        size_t          width;
        size_t          height;
        size_t          bytesPerRow;
        size_t          bitsPerPixel;
        unsigned int    x, y;
        int             bgColorIndex;
        int             colorCount;
        unsigned char  *raster;
        struct pixel   *pixel;
        GifColorType   *lut;
        BOOL            interlace;
        int             interlacePass;
        int             interlaceDelta;
        int             block;
        
        colorMap        = gif->SColorMap;
        lut             = colorMap->Colors;
        image           = gif->SavedImages + currentImage;
        width           = image->ImageDesc.Width;
        height          = image->ImageDesc.Height;
        bytesPerRow     = width*sizeof(struct pixel);
        bitsPerPixel    = 32;
        pixels          = NSZoneMalloc(NULL, bytesPerRow * height);
        pixel           = pixels;
        bgColorIndex    = (gif->SColorMap==NULL) ? -1 : gif->SBackGroundColor;
        raster          = image->RasterBits;
        colorCount      = colorMap->ColorCount;
        interlace       = image->ImageDesc.Interlace;
        interlacePass   = 1;
        interlaceDelta  = 8;

        size.width = width;
        size.height = height;
        
        /* Defalt delay */
        data[currentImage].delay = 0;
        data[currentImage].texId = 0;
        
        for (block = 0; block < image->ExtensionBlockCount; block++) {
            ExtensionBlock *theBlock = image->ExtensionBlocks+block;
            int delay;
            
            if (theBlock->ByteCount == 4 && theBlock->Function == 0xF9) {
                delay = theBlock->Bytes[2]<<8 | theBlock->Bytes[1];
                
                // Convert GIF's centiseconds into milliseconds
                data[currentImage].delay = delay*10;
                
                // See if the transparency is different for this frame
                if (theBlock->Bytes[0] & 1)
                    bgColorIndex = 0xff & theBlock->Bytes[3];
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

        for (y=0; y<height; y++) {
            for (x=0; x<width; x++) {
                unsigned char colorIndex = *raster;
                
                if(colorIndex == bgColorIndex) {
                    pixel->a = 0;
                    pixel->r = 255;
                    pixel->g = 0;
                    pixel->b = 255;
                }
                else if(colorIndex < colorCount) {
                    GifColorType *gifColor = lut+colorIndex;
                    
                    pixel->a = 255;
                    pixel->r = gifColor->Red;
                    pixel->g = gifColor->Green;
                    pixel->b = gifColor->Blue;
                }
                else {
                    pixel->a = 0;
                    pixel->r = 0;
                    pixel->g = 255;
                    pixel->b = 0;
                }
                pixel++;
                raster++;
            }
            
            if(interlace) {
                pixel += (interlaceDelta-1)*width;
                if((void *)pixel >= pixels+width*height){
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
    }
    
    DGifCloseFile(gif);
    
    millisLeft = data[0].delay;
    
    return self;
}

/* Call this once every 10ms or so */
- (BOOL)tick:(long long)elapsed {
    BOOL changed = NO;
    while (elapsed > 0 && data[currentFrame].delay) {
        if (elapsed > millisLeft) {
            elapsed -= millisLeft;
            currentFrame++;
            if (currentFrame >= totalFrames)
                currentFrame = 0;
            millisLeft = data[currentFrame].delay;
            changed = YES;
        }
        else {
            millisLeft -= elapsed;
            elapsed = 0;
        }
    }
    return changed;
}

- (void *)data {
    return data[currentFrame].pixels;
}

- (int)width {
    return size.width;
}

- (int)height {
    return size.height;
}


/* Resets back to frame #0 */
- (void)reset {
    currentFrame = 0;
}


- (unsigned int)textureId {
    return data[currentFrame].texId;
}

- (void)setTextureId:(unsigned int)tex
{
    data[currentFrame].texId = tex;
}


@end
