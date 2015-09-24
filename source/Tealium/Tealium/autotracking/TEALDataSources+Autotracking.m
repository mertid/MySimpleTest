//
//  TEALDatasources.m
//  Tealium
//
//  Created by Jason Koo on 8/5/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALDataSources+Autotracking.h"
#import <objc/runtime.h>
#import "TEALDataSourceConstants.h"
#import "TEALIDGenerator.h"

@implementation TEALDataSources (Autotracking)

#pragma mark - PUBLIC CLASS METHODS

+ (NSDictionary *) autotrackDataSourcesForDispatchType:(TEALDispatchType)dispatchType
                                   withObject:(NSObject *)obj {
    
    NSMutableDictionary *datasources = [NSMutableDictionary dictionary];
    
    datasources[TEALDataSourceKey_Autotracked] = TEALDataSourceValue_True;
    
    if (dispatchType == TEALDispatchTypeEvent) {
        [datasources addEntriesFromDictionary:[self dataForEventCalls:obj]];
    }
    
    if (dispatchType == TEALDispatchTypeView) {
        [datasources addEntriesFromDictionary:[self dataForViewCalls:obj]];
    }
    
    [datasources addEntriesFromDictionary:[self objectClassDataFor:obj]];
    
    NSString *tealiumID = [TEALIDGenerator tealiumIdForObject:obj];
    if (tealiumID) datasources[TEALDataSourceKey_TealiumID] = tealiumID;
        
    return [NSDictionary dictionaryWithDictionary:datasources];
}

+ (NSDictionary *) ivarDataForObject:(NSObject *)object {
    // requires <objc/runtime.h>
    
    __block NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([object class], &count);
    
    for (unsigned int i = 0; i < count; i++) {
        if (!properties[i]) continue;
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if (!key) continue;
        
        SEL aSelector = NSSelectorFromString(key);
        if ([object respondsToSelector:aSelector]){
            id aObject;
            @try                            {
                aObject = [object valueForKey:key];
            }
            @catch (NSException *exception) {                                       }
            @finally                        {                                       }
            
            if (![aObject isKindOfClass:[NSString class]] &&
                ![aObject isKindOfClass:[NSNumber class]] &&
                [aObject isKindOfClass:[NSObject class]]) aObject = NSStringFromClass([aObject class]);
            
            NSString * modKey = [NSString stringWithFormat:@"ivar_%@", key];
            if (aObject) mDict[modKey] = aObject;
        }
    }
    
    free(properties);
    
    NSDictionary *propertyDict = [NSDictionary dictionaryWithDictionary:mDict];
    return propertyDict;
}

#pragma mark - PRIVATE CLASS METHODS

+ (NSString *) titleForEvent:(TEALDispatchType)eventType
                  withObject:(NSObject *)obj {
    
    NSString *title = nil;
    
    switch (eventType) {
        case TEALDispatchTypeEvent:
            title = [TEALDataSources titleForTouchEventWithObject:obj];
            break;
            
        case TEALDispatchTypeView:
            title = [TEALDataSources titleForViewEventWithObject:obj];
            break;
        default:
            break;
    }
    
    return title;
}

+ (NSString *) titleForTouchEventWithObject:(NSObject *)obj {
    
    NSString *title = nil;
    
    if ([obj respondsToSelector:@selector(title)]) {
        
        title = [obj performSelector:@selector(title)];
        
    } else if ([obj respondsToSelector:@selector(currentTitle)]) {
        
        title = [obj performSelector:@selector(currentTitle)];
        
    } else if ([obj respondsToSelector:@selector(possibleTitles)]) {
        
        NSSet *titles = [obj performSelector:@selector(possibleTitles)];
        title = [titles anyObject];
        
    } else if ([obj respondsToSelector:@selector(selectedSegmentIndex)] &&
               [obj respondsToSelector:@selector(titleForSegmentAtIndex:)]) {
        
        UISegmentedControl *seg = (UISegmentedControl *)obj;
        int si = (int)[seg selectedSegmentIndex];
        int s = (int)[seg numberOfSegments];
        if (si >= 0 && si < s) title = [seg titleForSegmentAtIndex:si];
        
    } else if ([obj respondsToSelector:@selector(titleLabel)]) {
        
        UILabel *label =  [obj performSelector:@selector(titleLabel)];
        title = [label text];
    }
    return title;
}

+ (NSDictionary*) dataForEventCalls:(id)sender{
    
    NSString    *linkId = nil;
    NSString    *title = [TEALDataSources titleForEvent:sender];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    if (title) {
        data[TEALDataSourceKey_SelectedTitle] = title;
        linkId = [linkId stringByAppendingFormat:@": %@", title];
    }
    if (linkId) data[TEALDataSourceKey_EventTitle] = linkId;
    
    data[TEALDataSourceKey_CallType] = [TEALDispatch stringFromDispatchType:TEALDispatchTypeEvent];
    
    return [NSDictionary dictionaryWithDictionary:data];
}

+ (NSDictionary*) dataForViewCalls:(id)sender{
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    NSString    *title = [TEALDataSources titleForView:sender];
    
    if (title) data[TEALDataSourceKey_ViewTitle] = title;
    
    data[TEALDataSourceKey_CallType] = [TEALDispatch stringFromDispatchType:TEALDispatchTypeView];
    
    return [NSDictionary dictionaryWithDictionary:data];
}

+ (NSDictionary*) dataForView:(UIView*)view{
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    float width = view.frame.size.width;
    float height = view.frame.size.height;
    NSNumber *w = @(width);
    NSNumber *h = @(height);
    if (w && h) {
        mDict[TEALDataSourceKey_ViewHeight] = h;
        mDict[TEALDataSourceKey_ViewWidth] = w;
    }
    if (mDict) return mDict;
    return nil;
}

+ (NSDictionary*) objectClassDataFor:(id)sender{
    
    // convert any nsvalues back to object actual
    NSValue *value;
    if ([sender isKindOfClass:[NSValue class]]){
        value = sender;
        sender = [value nonretainedObjectValue];
        if (!sender) return @{};
    }
    
    // standardized return values
    NSString    *objectClass = [TEALDataSources objectClassFor:sender];
    NSString    *subTitle = [TEALDataSources subTitleFor:sender];
    NSString    *selectedRow = nil;
    NSString    *selectedSection = nil;
    NSString    *selectedValue = [TEALDataSources selectedValueFor:sender];
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    if ([sender isKindOfClass:([UITableView class])]){
        selectedRow = [self selectedRowFor:sender];
        selectedSection = [self selectedSectionFor:sender];
    }
    
    if ([sender isKindOfClass:[UIViewController class]]){
        UIViewController *vc = sender;
        [mDict addEntriesFromDictionary:[TEALDataSources dataForView:vc.view]];
        
    } else if ([sender isKindOfClass:[UIWebView class]]){
        UIWebView *webView = sender;
        [mDict addEntriesFromDictionary:[TEALDataSources dataForWebView:webView]];
        [mDict addEntriesFromDictionary:[TEALDataSources dataForView:webView]];
        
    } else if ([sender isKindOfClass:[UIImagePickerController class]]){
        UIImagePickerController *picker = sender;
        [mDict addEntriesFromDictionary:[TEALDataSources imagePickerData:picker]];
        
    } else if ([sender isKindOfClass:[NSException class]]){
        NSException *exception = sender;
        NSString *name = exception.name;
        NSString *reason = exception.reason;
        NSArray *traceArray = exception.callStackSymbols;
        NSString *trace = [NSString stringWithFormat:@"%@", traceArray];
        NSMutableDictionary *eventDict = [NSMutableDictionary dictionary];
        
        if (name) eventDict[TEALDataSourceKey_ExceptionName] = name;
        if (reason) eventDict[TEALDataSourceKey_ExceptionReason] = reason;
        if (trace) eventDict[TEALDataSourceKey_ExceptionTrace] = trace;
    }
    
    if (objectClass)    mDict[TEALDataSourceKey_ObjectClass] = objectClass;
    if (subTitle)       [mDict setObject:subTitle forKey:@"subtitle"];
    if (selectedRow)     mDict[TEALDataSourceKey_SelectedRow] = selectedRow;
    if (selectedSection) mDict[TEALDataSourceKey_SelectedSection] = selectedSection;
    if (selectedValue)  mDict[TEALDataSourceKey_SelectedValue] = selectedValue;
    
    NSDictionary *dict = [[NSDictionary alloc]initWithDictionary:mDict];
    
    return dict;
}

#pragma mark - CLASS DATA EXTRACTION

+ (BOOL) isObjectProtected:(id)obj {
    if ([obj isKindOfClass:([UITextField class])]) {
        return YES;
    }
    if ([obj isKindOfClass:[UITextView class]]) {
        return YES;
    }
    return NO;
}

+ (NSDictionary*) dataForWebView:(UIWebView*)webView{
    NSString *serviceType = TEALDataSourceValue_Unknown;
    NSURLRequest *request = webView.request;
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    switch (request.networkServiceType) {
        case 0:
            serviceType = @"default";
            break;
        case 1:
            serviceType = @"voip";
            break;
        case 2:
            serviceType = @"video";
            break;
        case 3:
            serviceType = @"background";
            break;
        case 4:
            serviceType = @"voice";
            break;
        default:
            serviceType = TEALDataSourceValue_Unknown;
            break;
    }
    
    NSString *url = request.URL.absoluteString;
    
    if (serviceType)  mDict[TEALDataSourceKey_WebViewServiceType] = serviceType;
    if (url)          mDict[TEALDataSourceKey_WebViewURL] = url;
    
    return mDict;
}

+ (NSDictionary*) imagePickerData:(UIImagePickerController*)picker{
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    NSString *sourceType = nil;
    NSString *cameraType = nil;
    NSString *cameraFlashMode = nil;
    
    switch (picker.sourceType) {
        case UIImagePickerControllerSourceTypeCamera:
            sourceType = @"camera";
            switch (picker.cameraDevice) {
                case UIImagePickerControllerCameraDeviceFront:
                    cameraType = @"front";
                    break;
                case UIImagePickerControllerCameraDeviceRear:
                    cameraType = @"rear";
                    break;
                default:
                    break;
            }
            switch (picker.cameraFlashMode) {
                case UIImagePickerControllerCameraFlashModeAuto:
                    cameraFlashMode = @"auto";
                    break;
                case UIImagePickerControllerCameraFlashModeOff:
                    cameraFlashMode = @"off";
                    break;
                case UIImagePickerControllerCameraFlashModeOn:
                    cameraFlashMode = @"on";
                    break;
                    
                default:
                    break;
            }
            break;
        case UIImagePickerControllerSourceTypePhotoLibrary:
            sourceType = @"photo_library";
            break;
        case UIImagePickerControllerSourceTypeSavedPhotosAlbum:
            sourceType = @"photo_album";
            break;
        default:
            break;
    }
    
    NSString *videoQuality = nil;
    switch (picker.videoQuality) {
        case UIImagePickerControllerQualityTypeHigh:
            videoQuality = @"high";
            break;
        case UIImagePickerControllerQualityTypeMedium:
            videoQuality = @"medium";
            break;
        case UIImagePickerControllerQualityTypeLow:
            videoQuality = @"low";
            break;
        case UIImagePickerControllerQualityType640x480:
            videoQuality = @"640x480";
            break;
        case UIImagePickerControllerQualityTypeIFrame1280x720:
            videoQuality = @"1280x720";
            break;
        case UIImagePickerControllerQualityTypeIFrame960x540:
            videoQuality = @"960x540";
            break;
        default:
            break;
    }
    
    if (sourceType) [mDict setObject:sourceType forKey:@"source_type"];
    if (cameraType) [mDict setObject:cameraType forKey:@"camera_type"];
    if (cameraFlashMode) [mDict setObject:cameraFlashMode forKey:@"camera_flash"];
    if (videoQuality) [mDict setObject:videoQuality forKey:@"video_quality"];
    
    return [NSDictionary dictionaryWithDictionary:mDict];
}

+ (NSString*) objectClassFor:(id) obj{
    NSString *string = nil;
    if ([obj respondsToSelector:@selector(class)])
        string = NSStringFromClass([obj class]);
    
    return string;
}

+ (NSString*) selectedRowFor:(UITableView*)obj{
    NSString *string = nil;
    UITableView *tv = obj;
    NSIndexPath *ip = [tv indexPathForSelectedRow];
    string = [NSString stringWithFormat:@"%li", (long)ip.row];
    return string;
}

+ (NSString*) selectedSectionFor:(UITableView*)obj{
    NSString *string = nil;
    UITableView *tv = obj;
    NSIndexPath *ip = [tv indexPathForSelectedRow];
    string = [NSString stringWithFormat:@"%li", (long)ip.section];
    return string;
}

+ (NSString*) selectedValueFor:(id) obj{
    NSString *string = nil;
    
    if ([obj isKindOfClass:[UITableView class]]){
        UITableView *tv = obj;
        NSIndexPath *ip = [tv indexPathForSelectedRow];
        string = [NSString stringWithFormat:@"[%li %li]", (long)ip.section, (long)ip.row];
    }
    if ([obj isKindOfClass:[UISegmentedControl class]]){
        UISegmentedControl *aSegment = obj;
        string = [NSString stringWithFormat:@"%li", (long)aSegment.selectedSegmentIndex];
    }
    if ([obj isKindOfClass:[UISlider class]]){
        UISlider *aSlider = obj;
        string = [NSString stringWithFormat:@"%.02f", aSlider.value];
    }
    if ([obj isKindOfClass:[UISwitch class]]){
        UISwitch *aSwitch = obj;
        string = [NSString stringWithFormat:@"%d", aSwitch.on];
    }
    if ([obj isKindOfClass:[UIStepper class]]){
        UIStepper *aStepper = obj;
        string = [NSString stringWithFormat:@"%1.0f", aStepper.value];
    }
    return string;
}

+ (NSString*) subTitleFor:(id) obj{
    NSString *string = nil;
    
    if ([obj isKindOfClass:([UITableView class])]){
        UITableView *tableView = obj;
        NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
        UITableViewCell *object = [tableView cellForRowAtIndexPath:indexPath];
        string = object.detailTextLabel.text;
    }
    if ([obj isKindOfClass:([UITableViewCell class])]){
        UITableViewCell *cell = obj;
        string = cell.detailTextLabel.text;
    }
    return string;
}

+ (NSString*) titleForEvent:(id)obj{
    NSString *title = nil;
    
    if ([obj respondsToSelector:@selector(title)]){
        title = [obj title];
    }
    if (!title &&
        [obj respondsToSelector:@selector(currentTitle)]){
        title = [obj currentTitle];
    }
    if (!title &&
        [obj respondsToSelector:@selector(possibleTitles)]){
        NSSet *titles = [obj possibleTitles];
        title = [titles anyObject];
    }
    if (!title &&
        [obj respondsToSelector:@selector(selectedSegmentIndex)] &&
        [obj respondsToSelector:@selector(titleForSegmentAtIndex:)]) {
        UISegmentedControl *seg = obj;
        int si = (int)[seg selectedSegmentIndex];
        int s = (int)[seg numberOfSegments];
        if (si >= 0 && si < s) title = [obj titleForSegmentAtIndex:si];
    }
    if (!title &&
        [obj respondsToSelector:@selector(titleLabel)]){
        title = [[obj titleLabel] text];
    }
    return title;
}

+ (NSString*) titleForView:(NSObject *)obj{
    NSString *title = @"";
    
    if ([obj respondsToSelector:@selector(canGoBack)]){
        title = @"webview";
    }
    if ([obj respondsToSelector:@selector(title)]){
        title = [obj performSelector:@selector(title)];
    }
    if (!title &&
        [obj respondsToSelector:@selector(currentTitle)]){
        title = [obj performSelector:@selector(currentTitle)];
    }
    if (!title && [obj respondsToSelector:@selector(restorationIdentifier)]){
        title = [obj performSelector:@selector(restorationIdentifier)];
    }
    if (!title &&
        [obj respondsToSelector:@selector(possibleTitles)]){
        NSSet *titles = [obj performSelector:@selector(possibleTitles)];
        title = [titles anyObject];
    }
    if (!title && [obj respondsToSelector:@selector(nibName)]) {
        title = [obj performSelector:@selector(nibName)];
    }
    if (!title) {
        NSString *objClass = [TEALDataSources objectClassFor:obj];
        if (objClass) title = objClass;
    }
    
    return title;
}

@end
