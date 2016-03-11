//
//  AssetHelper.m
//  DoImagePickerController
//
//  Created by Donobono on 2014. 1. 23..
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#define ASSETHELPER    [AssetHelper sharedAssetHelper]

#define ASSET_PHOTO_THUMBNAIL           0//缩略图
#define ASSET_PHOTO_SCREEN_SIZE         1//
#define ASSET_PHOTO_FULL_RESOLUTION     2//分辨率

@interface AssetHelper : NSObject

- (void)initAsset;

//可以实现查看相册列表，增加相册，保存图片到相册等功能
@property (nonatomic, strong)   ALAssetsLibrary			*assetsLibrary;

@property (nonatomic, strong)   NSMutableArray          *assetPhotos;
@property (nonatomic, strong)   NSMutableArray          *assetGroups;

@property (readwrite)           BOOL                    bReverse;

+ (AssetHelper *)sharedAssetHelper;

// get album list from asset
- (void)getGroupList:(void (^)(NSArray *))result;
// get photos from specific album with ALAssetsGroup object
- (void)getPhotoListOfGroup:(ALAssetsGroup *)alGroup result:(void (^)(NSArray *))result;
// get photos from specific album with index of album array
- (void)getPhotoListOfGroupByIndex:(NSInteger)nGroupIndex result:(void (^)(NSArray *))result;
// get photos from camera roll
- (void)getSavedPhotoList:(void (^)(NSArray *))result error:(void (^)(NSError *))error;

- (NSInteger)getGroupCount;
- (NSInteger)getPhotoCountOfCurrentGroup;
- (NSDictionary *)getGroupInfo:(NSInteger)nIndex;

- (void)clearData;

// utils
- (UIImage *)getCroppedImage:(NSURL *)urlImage;
- (UIImage *)getImageFromAsset:(ALAsset *)asset type:(NSInteger)nType;
- (UIImage *)getImageAtIndex:(NSInteger)nIndex type:(NSInteger)nType;
- (ALAsset *)getAssetAtIndex:(NSInteger)nIndex;

@end

