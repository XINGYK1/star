//
//  DoImagePickerController.m
//  DoImagePickerController
//
//  Created by Donobono on 2014. 1. 23..
//



#import "DoImagePickerController.h"
#import "AssetHelper.h"
#import "ShowPhotoViewController.h"
#import "DoAlbumCell.h"
#import "DoPhotoCell.h"
#import "WXNavigationController.h"
@implementation DoImagePickerController
{
    
    NSMutableArray *_aResult;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    _aResult = [[NSMutableArray alloc]initWithCapacity:_dSelected.count];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self initBottomMenu];
    
    [self initControls];
    
    UINib *nib = [UINib nibWithNibName:@"DoPhotoCell" bundle:nil];
    [_cvPhotoList registerNib:nib forCellWithReuseIdentifier:@"DoPhotoCell"];
    _cvPhotoList.backgroundColor = [UIColor clearColor];
     _tvAlbumList.alpha = 0.0;

    [self readAlbumList];

    // new photo is located at the first of array
    ASSETHELPER.bReverse = YES;
	
	if (_nMaxCount != 1)
	{
		// init gesture for multiple selection with panning
		UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanForSelection:)];
		[self.view addGestureRecognizer:pan];
	}

    // init gesture for preview
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongTapForPreview:)];
    longTap.minimumPressDuration = 0.3;
    [self.view addGestureRecognizer:longTap];
    
    // add observer for refresh asset data
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnterForeground:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_nResultType == DO_PICKER_RESULT_UIIMAGE)
        [ASSETHELPER clearData];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}



- (void)handleEnterForeground:(NSNotification*)notification
{
    [self readAlbumList];
}

#pragma mark - for init
- (void)initControls
{
    // side buttons
    _btUp.backgroundColor = DO_SIDE_BUTTON_COLOR;
    _btDown.backgroundColor = DO_SIDE_BUTTON_COLOR;
    
    CALayer *layer1 = [_btDown layer];
	[layer1 setMasksToBounds:YES];
	[layer1 setCornerRadius:_btDown.frame.size.height / 2.0 - 1];
    
    CALayer *layer2 = [_btUp layer];
	[layer2 setMasksToBounds:YES];
	[layer2 setCornerRadius:_btUp.frame.size.height / 2.0 - 1];
    
    // table view
    UIImageView *ivHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _tvAlbumList.frame.size.width, 0.5)];
    ivHeader.backgroundColor = DO_ALBUM_NAME_TEXT_COLOR;
    _tvAlbumList.tableHeaderView = ivHeader;
    
    UIImageView *ivFooter = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _tvAlbumList.frame.size.width, 0.5)];
    ivFooter.backgroundColor = DO_ALBUM_NAME_TEXT_COLOR;
    _tvAlbumList.tableFooterView = ivFooter;
    
    // dimmed view
    _vDimmed.alpha = 0.0;
    _vDimmed.frame = self.view.frame;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapOnDimmedView:)];
    [_vDimmed addGestureRecognizer:tap];
}

- (void)readAlbumList
{
    [ASSETHELPER getGroupList:^(NSArray *aGroups) {
        
        [_tvAlbumList reloadData];
        [_tvAlbumList selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        
        [_btSelectAlbum setTitle:[ASSETHELPER getGroupInfo:0][@"name"] forState:UIControlStateNormal];
        [self showPhotosInGroup:0];
        
        if (aGroups.count == 1)
            _btSelectAlbum.enabled = NO;
        
        // calculate tableview's height
     }];
}

#pragma mark - for bottom menu
- (void)initBottomMenu
{
    _ivLine1.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"line.png"]];
    
    _ivLine2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"line.png"]];
    
    //如果最大选择数等于-1
    if (_nMaxCount == DO_NO_LIMIT_SELECT)
    {
        _lbSelectCount.text = @"(0)";
        _lbSelectCount.textColor = DO_BOTTOM_TEXT_COLOR;
        
    }else if (_nMaxCount <= 1){
        //如果选择数
        // hide ok button
        _btOK.hidden = YES;
        _ivLine1.hidden = YES;
        
        CGRect rect = _btSelectAlbum.frame;
        rect.size.width = rect.size.width + 60;
        _btSelectAlbum.frame = rect;
        _lbSelectCount.hidden = YES;
    }else{
        _lbSelectCount.text = [NSString stringWithFormat:@"(0/%d)", (int)_nMaxCount];

    }
}


#pragma mark -完成按钮的点击方法
- (IBAction)onSelectPhoto:(id)sender
{
    if (self.flag) {
        //如果flag为YES 执行以下的方法
        
        //用这种方法可以提高程序的运行速度
        _aResult = [[NSMutableArray alloc] initWithCapacity:_dSelected.count];
        
        NSArray *aKeys = [_dSelected keysSortedByValueUsingSelector:@selector(compare:)];
        
        if (_nResultType == DO_PICKER_RESULT_UIIMAGE)
        {
            for (int i = 0; i < _dSelected.count; i++)
                //先选X张，再加一张会崩在这
                //ASSETHELPER获取ASSETHELPER单例
                [_aResult addObject:[ASSETHELPER getImageAtIndex:[aKeys[i] integerValue] type:ASSET_PHOTO_SCREEN_SIZE]];
        }else{
            for (int i = 0; i < _dSelected.count; i++)
                
                [_aResult addObject:[ASSETHELPER getAssetAtIndex:[aKeys[i] integerValue]]];
        }

        //在这里把选择的照片传给ShowPhotoViewController的图片数组
        ShowPhotoViewController *showVC = [[ShowPhotoViewController alloc]init];
        
        [showVC setPhotoNameList:_aResult];
        
        
        //并且模态试图到ShowPhotoViewController
        WXNavigationController *nav = [[WXNavigationController alloc]initWithRootViewController:showVC];
        
        [self presentViewController:nav animated:NO completion:nil];
        

    }else{
    
        ////如果flag为NO执行以下的方法
        
        NSMutableArray *aResult = [[NSMutableArray alloc] initWithCapacity:_dSelected.count];
        
        NSArray *aKeys = [_dSelected keysSortedByValueUsingSelector:@selector(compare:)];
        
        if (_nResultType == DO_PICKER_RESULT_UIIMAGE)
        {
            for (int i = 0; i < _dSelected.count; i++)
                [aResult addObject:[ASSETHELPER getImageAtIndex:[aKeys[i] integerValue] type:ASSET_PHOTO_SCREEN_SIZE]];
        }
        else
        {
            for (int i = 0; i < _dSelected.count; i++)
                [aResult addObject:[ASSETHELPER getAssetAtIndex:[aKeys[i] integerValue]]];
        }
        
        [_delegate didSelectPhotosFromDoImagePickerController:self result:aResult];
    }
    
    //self.flag = !self.flag;
    
}

- (IBAction)onCancel:(id)sender
{
    NSLog(@"keys : %@", _dSelected.allKeys );
    NSLog(@"values : %@", _dSelected);
    
    [_delegate didCancelDoImagePickerController];
}

- (IBAction)onSelectAlbum:(id)sender
{
    if (_tvAlbumList.frame.origin.y == 55)
    {
        // show tableview
        [UIView animateWithDuration:0.2 animations:^(void) {

            _vDimmed.alpha = 0.7;

             _tvAlbumList.alpha = 1.0;
            
//            _ivShowMark.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }
    else
    {
        // hide tableview
        [self hideBottomMenu];
    }
}

#pragma mark - for side buttons
- (void)onTapOnDimmedView:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        [self hideBottomMenu];
        
        if (_ivPreview != nil)
            [self hidePreview];
    }
}

- (IBAction)onUp:(id)sender
{
    [_cvPhotoList scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (IBAction)onDown:(id)sender
{
    [_cvPhotoList scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[ASSETHELPER getPhotoCountOfCurrentGroup] - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

#pragma mark - UITableViewDelegate for selecting album
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ASSETHELPER getGroupCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DoAlbumCell *cell = (DoAlbumCell*)[tableView dequeueReusableCellWithIdentifier:@"DoAlbumCell"];
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DoAlbumCell" owner:nil options:nil] lastObject];
    }

    NSDictionary *d = [ASSETHELPER getGroupInfo:indexPath.row];
    cell.lbAlbumName.text   = [NSString stringWithFormat:@"%@  %@", d[@"name"],d[@"count"]];

	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showPhotosInGroup:indexPath.row];
    [_btSelectAlbum setTitle:[ASSETHELPER getGroupInfo:indexPath.row][@"name"] forState:UIControlStateNormal];

    [self hideBottomMenu];
}
 
- (void)hideBottomMenu
{
    [UIView animateWithDuration:0.2 animations:^(void) {
        
        _vDimmed.alpha = 0.0;
        
         _ivShowMark.transform = CGAffineTransformMakeRotation(0);
        
        [UIView setAnimationDelay:0.1];

        _tvAlbumList.alpha = 0.0;
    }];
}

#pragma mark - UICollectionViewDelegates for photos
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [ASSETHELPER getPhotoCountOfCurrentGroup];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DoPhotoCell *cell = (DoPhotoCell *)[_cvPhotoList dequeueReusableCellWithReuseIdentifier:@"DoPhotoCell" forIndexPath:indexPath];

    cell.ivPhoto.image = [ASSETHELPER getImageAtIndex:indexPath.row type:ASSET_PHOTO_THUMBNAIL];

	if (_dSelected[@(indexPath.row)] == nil)
		[cell setSelectMode:NO];
    else
		[cell setSelectMode:YES];
	
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_nMaxCount > 1 || _nMaxCount == DO_NO_LIMIT_SELECT)
    {
		DoPhotoCell *cell = (DoPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
		if ((_dSelected[@(indexPath.row)] == nil) && (_nMaxCount > _dSelected.count))
		{
			// select  选图片1
            _dSelected[@(indexPath.row)] = @(_dSelected.count);
			
            [cell setSelectMode:YES];
		}
		else
		{
			// unselect 取消图片1
			[_dSelected removeObjectForKey:@(indexPath.row)];
			[cell setSelectMode:NO];
		}
        
        if (_nMaxCount == DO_NO_LIMIT_SELECT)
            
            _lbSelectCount.text = [NSString stringWithFormat:@"(%d)", (int)_dSelected.count];
        else//选图片2/取消图片2
            _lbSelectCount.text = [NSString stringWithFormat:@"(%d/%d)", (int)_dSelected.count, (int)_nMaxCount];
    }
    else
    {
        if (_nResultType == DO_PICKER_RESULT_UIIMAGE)
            [_delegate didSelectPhotosFromDoImagePickerController:self result:@[[ASSETHELPER getImageAtIndex:indexPath.row type:ASSET_PHOTO_SCREEN_SIZE]]];
        else
            [_delegate didSelectPhotosFromDoImagePickerController:self result:@[[ASSETHELPER getAssetAtIndex:indexPath.row]]];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat kYTHWAndH = (YTHScreenWidth - (_nColumnCount-1)*4)/_nColumnCount;
    return CGSizeMake(kYTHWAndH, kYTHWAndH);
//    if (_nColumnCount == 2)
//        return CGSizeMake(158, 158);
//    else if (_nColumnCount == 3)
//        return CGSizeMake(104, 104);
//    else if (_nColumnCount == 4)
//        return CGSizeMake(77, 77);
//
//    return CGSizeZero;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _cvPhotoList)
    {
        [UIView animateWithDuration:0.2 animations:^(void) {
            if (scrollView.contentOffset.y <= 50)
                _btUp.alpha = 0.0;
            else
                _btUp.alpha = 1.0;
            
            if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height)
                _btDown.alpha = 0.0;
            else
                _btDown.alpha = 1.0;
        }];
    }
}

// for multiple selection with panning
- (void)onPanForSelection:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (_ivPreview != nil)
        return;
    
    double fX = [gestureRecognizer locationInView:_cvPhotoList].x;
    double fY = [gestureRecognizer locationInView:_cvPhotoList].y;
	
    for (UICollectionViewCell *cell in _cvPhotoList.visibleCells)
	{
        float fSX = cell.frame.origin.x;
        float fEX = cell.frame.origin.x + cell.frame.size.width;
        float fSY = cell.frame.origin.y;
        float fEY = cell.frame.origin.y + cell.frame.size.height;
        
        if (fX >= fSX && fX <= fEX && fY >= fSY && fY <= fEY)
        {
            NSIndexPath *indexPath = [_cvPhotoList indexPathForCell:cell];
            
            if (_lastAccessed != indexPath)
            {
				[self collectionView:_cvPhotoList didSelectItemAtIndexPath:indexPath];
            }
            
            _lastAccessed = indexPath;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        _lastAccessed = nil;
        _cvPhotoList.scrollEnabled = YES;
    }
}

// for preview
- (void)onLongTapForPreview:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (_ivPreview != nil)
        return;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        double fX = [gestureRecognizer locationInView:_cvPhotoList].x;
        double fY = [gestureRecognizer locationInView:_cvPhotoList].y;
        
        NSIndexPath *indexPath = nil;
        for (UICollectionViewCell *cell in _cvPhotoList.visibleCells)
        {
            float fSX = cell.frame.origin.x;
            float fEX = cell.frame.origin.x + cell.frame.size.width;
            float fSY = cell.frame.origin.y;
            float fEY = cell.frame.origin.y + cell.frame.size.height;
            
            if (fX >= fSX && fX <= fEX && fY >= fSY && fY <= fEY)
            {
                indexPath = [_cvPhotoList indexPathForCell:cell];
                break;
            }
        }
        
        if (indexPath != nil)
            [self showPreview:indexPath.row];
    }
}

#pragma mark - for photos
- (void)showPhotosInGroup:(NSInteger)nIndex
{
    if (_nMaxCount == DO_NO_LIMIT_SELECT)
    {
        _dSelected = [[NSMutableDictionary alloc] init];
        _lbSelectCount.text = @"(0)";
    }
    else if (_nMaxCount > 1)
    {
        _dSelected = [[NSMutableDictionary alloc] initWithCapacity:_nMaxCount];
        _lbSelectCount.text = [NSString stringWithFormat:@"(0/%d)", (int)_nMaxCount];
    }
    
    [ASSETHELPER getPhotoListOfGroupByIndex:nIndex result:^(NSArray *aPhotos) {
        
        [_cvPhotoList reloadData];
        
        _cvPhotoList.alpha = 0.3;
        [UIView animateWithDuration:0.2 animations:^(void) {
            [UIView setAnimationDelay:0.1];
            _cvPhotoList.alpha = 1.0;
        }];
        
		if (aPhotos.count > 0)
		{
			[_cvPhotoList scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }

        _btUp.alpha = 0.0;

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (_cvPhotoList.contentSize.height < _cvPhotoList.frame.size.height)
                _btDown.alpha = 0.0;
            else
                _btDown.alpha = 1.0;
        });
    }];
}

- (void)showPreview:(NSInteger)nIndex
{
    [self.view bringSubviewToFront:_vDimmed];
    
    _ivPreview = [[UIImageView alloc] initWithFrame:_vDimmed.frame];
    _ivPreview.contentMode = UIViewContentModeScaleAspectFit;
    _ivPreview.autoresizingMask = _vDimmed.autoresizingMask;
    [_vDimmed addSubview:_ivPreview];
    
    _ivPreview.image = [ASSETHELPER getImageAtIndex:nIndex type:ASSET_PHOTO_SCREEN_SIZE];
    
    // add gesture for close preview
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanToClosePreview:)];
    [_vDimmed addGestureRecognizer:pan];
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        _vDimmed.alpha = 1.0;
    }];
}

- (void)hidePreview
{
    [self.view bringSubviewToFront:_tvAlbumList];
    [self.view bringSubviewToFront:_vBottomMenu];
    
    [_ivPreview removeFromSuperview];
    _ivPreview = nil;

    _vDimmed.alpha = 0.0;
    [_vDimmed removeGestureRecognizer:[_vDimmed.gestureRecognizers lastObject]];
}

- (void)onPanToClosePreview:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self.view];

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:0.2 animations:^(void) {
            
            if (_vDimmed.alpha < 0.7)   // close preview
            {
                CGPoint pt = _ivPreview.center;
                if (_ivPreview.center.y > _vDimmed.center.y)
                    pt.y = self.view.frame.size.height * 1.5;
                else if (_ivPreview.center.y < _vDimmed.center.y)
                    pt.y = -self.view.frame.size.height * 1.5;

                _ivPreview.center = pt;

                [self hidePreview];
            }
            else
            {
                _vDimmed.alpha = 1.0;
                _ivPreview.center = _vDimmed.center;
            }
            
        }];
    }
    else
    {
		_ivPreview.center = CGPointMake(_ivPreview.center.x, _ivPreview.center.y + translation.y);
		[gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        
        _vDimmed.alpha = 1 - ABS(_ivPreview.center.y - _vDimmed.center.y) / (self.view.frame.size.height / 2.0);
    }
}

#pragma mark - Others
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
