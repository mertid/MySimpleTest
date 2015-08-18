//
//  TEALAutotrackDataSources.m
//  Tealium
//
//  Created by Jason Koo on 8/5/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALAutotrackDataSources.h"
#import "TEALDatasourceConstants.h"

@implementation TEALAutotrackDataSources


#pragma mark - PUBLIC CLASS METHODS

+ (NSDictionary *) datasourcesForDispatchType:(TEALDispatchType)dispatchType
                            withObject:(NSObject *)obj {
    
    NSMutableDictionary *datasources = [NSMutableDictionary dictionary];
    
    datasources[TEALDatasourceKey_Autotracked] = TEALDatasourceValue_True;
    
    
    if (dispatchType == TEALDispatchTypeEvent) {
        [datasources addEntriesFromDictionary:[TEALAutotrackDataSources dataForEventCalls:obj]];
    }
    
    if (dispatchType == TEALDispatchTypeView) {
        [datasources addEntriesFromDictionary:[TEALAutotrackDataSources dataForViewCalls:obj]];
    }
    
    [datasources addEntriesFromDictionary:[TEALAutotrackDataSources dynamicUIDeviceData]];
    
    [datasources addEntriesFromDictionary:[TEALAutotrackDataSources objectClassDataFor:obj]];
    
    return [NSDictionary dictionaryWithDictionary:datasources];
}

#pragma mark - PRIVATE CLASS METHODS

+ (NSString *) titleForEvent:(TEALDispatchType)eventType
                  withObject:(NSObject *)obj {
    
    NSString *title = nil;
    
    switch (eventType) {
        case TEALDispatchTypeEvent:
            title = [TEALAutotrackDataSources titleForTouchEventWithObject:obj];
            break;
            
        case TEALDispatchTypeView:
            title = [TEALAutotrackDataSources titleForViewEventWithObject:obj];
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

+ (NSString *) titleForViewEventWithObject:(NSObject *)obj {
    
    NSString *title = nil;
    
    if ([obj isKindOfClass:[UIWebView class]]) {
        title = @"webview";
        
    } else if ([obj respondsToSelector:@selector(title)]) {
        
        title = [obj performSelector:@selector(title)];
        
    } else if ([obj respondsToSelector:@selector(currentTitle)]) {
        
        title = [obj performSelector:@selector(currentTitle)];
        
    } else if ([obj respondsToSelector:@selector(possibleTitles)]) {
        
        NSSet *titles = [obj performSelector:@selector(possibleTitles)];
        title = [titles anyObject];
        
    } else if ([obj respondsToSelector:@selector(restorationIdentifier)]) {
        
        title = [obj performSelector:@selector(restorationIdentifier)];
        
    } else if ([obj respondsToSelector:@selector(nibName)]) {
        
        title = [obj performSelector:@selector(nibName)];
    }
    
    return title;
}

+ (NSDictionary*) dataForEventCalls:(id)sender{
    
    NSString    *linkId = nil;
    NSString    *title = [TEALAutotrackDataSources titleForEvent:sender];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    if (title) {
        data[TEALDatasourceKey_SelectedTitle] = title;
        linkId = [linkId stringByAppendingFormat:@": %@", title];
    }
    if (linkId) data[TEALDatasourceKey_EventTitle] = linkId;
    
    data[TEALDatasourceKey_CallType] = [TEALDispatch stringFromDispatchType:TEALDispatchTypeEvent];
    
    return [NSDictionary dictionaryWithDictionary:data];
}

+ (NSDictionary*) dataForViewCalls:(id)sender{
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    NSString    *title = [TEALAutotrackDataSources titleForView:sender];
    
    if (title) data[TEALDatasourceKey_ViewTitle] = title;
    
    data[TEALDatasourceKey_CallType] = [TEALDispatch stringFromDispatchType:TEALDispatchTypeView];
    
    return [NSDictionary dictionaryWithDictionary:data];
}

+ (NSDictionary*) dataForView:(UIView*)view{
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    float width = view.frame.size.width;
    float height = view.frame.size.height;
    NSNumber *w = [NSNumber numberWithFloat:width];
    NSNumber *h = [NSNumber numberWithFloat:height];
    if (w && h) {
        mDict[TEALDatasourceKey_ViewHeight] = h;
        mDict[TEALDatasourceKey_ViewWidth] = w;
    }
    if (mDict) return mDict;
    return nil;
}

+ (NSDictionary*) dynamicUIDeviceData {
    
    // get runtime changable default data
    NSString *batteryLevel = [TEALAutotrackDataSources batteryLevelAsPercentString];
    NSString *batteryIsCharging = [TEALAutotrackDataSources batteryIsChargingAsString];
    NSString *device = [[UIDevice currentDevice] model];
    NSString *orientation = [TEALAutotrackDataSources getOrientation];
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    
    // if particular data is not available, skip
    if (batteryLevel)                       mDict[TEALDatasourceKey_DeviceBatteryLevel] = batteryLevel;
    if (batteryIsCharging)                  mDict[TEALDatasourceKey_DeviceIsCharging] = batteryIsCharging;
    if (device)                             mDict[TEALDatasourceKey_Device] = device;
    if (orientation)                        mDict[TEALDatasourceKey_Orientation] = orientation;
    
    return [NSDictionary dictionaryWithDictionary:mDict];
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
    NSString    *objectClass = [TEALAutotrackDataSources objectClassFor:sender];
    NSString    *subTitle = [TEALAutotrackDataSources subTitleFor:sender];
    NSString    *selectedRow = nil;
    NSString    *selectedSection = nil;
    NSString    *selectedValue = [TEALAutotrackDataSources selectedValueFor:sender];
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    if ([sender isKindOfClass:([UITableView class])]){
        selectedRow = [self selectedRowFor:sender];
        selectedSection = [self selectedSectionFor:sender];
    }
    
    if ([sender isKindOfClass:[UIViewController class]]){
        UIViewController *vc = sender;
        [mDict addEntriesFromDictionary:[TEALAutotrackDataSources dataForView:vc.view]];
        
    } else if ([sender isKindOfClass:[UIWebView class]]){
        UIWebView *webView = sender;
        [mDict addEntriesFromDictionary:[TEALAutotrackDataSources dataForWebView:webView]];
        [mDict addEntriesFromDictionary:[TEALAutotrackDataSources dataForView:webView]];
        
    } else if ([sender isKindOfClass:[UIImagePickerController class]]){
        UIImagePickerController *picker = sender;
        [mDict addEntriesFromDictionary:[TEALAutotrackDataSources imagePickerData:picker]];
        
    } else if ([sender isKindOfClass:[NSException class]]){
        NSException *exception = sender;
        NSString *name = exception.name;
        NSString *reason = exception.reason;
        NSArray *traceArray = exception.callStackSymbols;
        NSString *trace = [TEALAutotrackDataSources stringifyExceptionTrace:traceArray];
        NSMutableDictionary *eventDict = [NSMutableDictionary dictionary];
        eventDict[TEALDatasourceKey_ExceptionType] = TEALDatasourceValue_ExceptionCaught;
        
        if (name) eventDict[TEALDatasourceKey_ExceptionName] = name;
        if (reason) eventDict[TEALDatasourceKey_ExceptionReason] = reason;
        if (trace) eventDict[TEALDatasourceKey_ExceptionTrace] = trace;
    }
    
    if (objectClass)    mDict[TEALDatasourceKey_ObjectClass] = objectClass;
    if (subTitle)       [mDict setObject:subTitle forKey:@"subtitle"];
    if (selectedRow)     mDict[TEALDatasourceKey_SelectedRow] = selectedRow;
    if (selectedSection) mDict[TEALDatasourceKey_SelectedSection] = selectedSection;
    if (selectedValue)  mDict[TEALDatasourceKey_SelectedValue] = selectedValue;
    
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

//+ (NSString*) accessibilityLabelFor:(id) obj{
//    NSString *string = nil;
//    
//    if ([obj respondsToSelector:@selector(accessibilityLabel)])
//        string = [obj accessibilityLabel];
//    return string;
//}

+ (NSString *) batteryLevelAsPercentString {
    
    float ddFloat = 0.0;
    
    if(![UIDevice currentDevice].isBatteryMonitoringEnabled){
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    }
    ddFloat = [UIDevice currentDevice].batteryLevel * 100;
    
    NSString *percentString = [NSString stringWithFormat:@"%.0f", ddFloat];
    
    if (percentString) {
        return percentString;
    } else {
        return TEALDatasourceValue_Unknown;
    }
}

+ (NSString *) batteryIsChargingAsString {
    
    NSString *string = @"false";
    
    if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging) {
        string = @"true";
    }
    
    return string;
}

+ (NSString*) currentLanguage{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if(language) return language;
    return nil;
}

+ (NSDictionary*) dataForWebView:(UIWebView*)webView{
    NSString *serviceType = TEALDatasourceValue_Unknown;
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
            serviceType = TEALDatasourceValue_Unknown;
            break;
    }
    
    NSString *url = request.URL.absoluteString;
    
    if (serviceType)  mDict[TEALDatasourceKey_WebViewServiceType] = serviceType;
    if (url)          mDict[TEALDatasourceKey_WebViewURL] = url;
    
    return mDict;
}

+ (NSString*) getOrientation {
    
    NSString *string = nil;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (interfaceOrientation == UIInterfaceOrientationPortrait) string = @"Portrait";
    else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) string = @"Portrait UpsideDown";
    
    // Interface orientation landscape left and right are opposite of device orientation landscape left and right
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) string = @"Landscape Right";
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) string = @"Landscape Left";
    
    if (string) {
        return string;
    }
    
    // Fallback
    
    UIDevice *device = [UIDevice currentDevice];
    if (device.orientation == UIDeviceOrientationPortrait) string = @"Portrait";
    else if (device.orientation == UIDeviceOrientationLandscapeLeft) string = @"Landscape Left";
    else if (device.orientation == UIDeviceOrientationLandscapeRight)string = @"Landscape Right";
    else if (device.orientation == UIDeviceOrientationPortraitUpsideDown) string = @"Portrait UpsideDown";
    else if (device.orientation == UIDeviceOrientationFaceUp) string = @"Face up";
    else if (device.orientation == UIDeviceOrientationFaceDown) string = @"Face Down";
    
    if (!string) {
        string = TEALDatasourceValue_Unknown;
    }
    
    return string;
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

+ (NSString*) stringifyExceptionTrace:(NSArray*)callStack{
    NSMutableString *mString = [NSMutableString string];
    for (NSString *string in callStack){
        [mString appendString:string];
    }
    return [NSString stringWithString:mString];
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

+ (NSString*) timestampAsISOFrom:(NSDate*)date{
    // modified from original by Radu Poenaru
    NSDateFormatter *_sISO8601 = nil;
    
    if (!_sISO8601) {
        _sISO8601 = [[NSDateFormatter alloc] init];
        
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_sISO8601 setTimeZone:timeZone];
        
        NSMutableString *strFormat = [NSMutableString stringWithString:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        
        [_sISO8601 setTimeStyle:NSDateFormatterFullStyle];
        [_sISO8601 setDateFormat:strFormat];
    }
    if (date) return[_sISO8601 stringFromDate:date];
    return nil;
}

+ (NSString*) timestampAsISOLocalFrom:(NSDate*) date{
    // modified from original by Radu Poenaru
    NSDateFormatter *_sISO8601Local = nil;
    if (!_sISO8601Local) {
        _sISO8601Local = [[NSDateFormatter alloc] init];
        
        NSMutableString *strFormat = [NSMutableString stringWithString:@"yyyy-MM-dd'T'HH:mm:ss"];
        [_sISO8601Local setTimeStyle:NSDateFormatterFullStyle];
        [_sISO8601Local setDateFormat:strFormat];
    }
    if (date) return[_sISO8601Local stringFromDate:date];
    return nil;
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

+ (NSString*) titleForView:(id)obj{
    NSString *title = @"";
    
    if ([obj isKindOfClass:[UIWebView class]]){
        title = @"webview";
    }
    if ([obj respondsToSelector:@selector(title)]){
        title = [obj title];
    }
    if (!title &&
        [obj respondsToSelector:@selector(currentTitle)]){
        title = [obj currentTitle];
    }
    if (!title && [obj respondsToSelector:@selector(restorationIdentifier)]){
        title = [obj restorationIdentifier];
    }
    if (!title &&
        [obj respondsToSelector:@selector(possibleTitles)]){
        NSSet *titles = [obj possibleTitles];
        title = [titles anyObject];
    }
    if (!title && [obj respondsToSelector:@selector(nibName)]) {
        title = [obj nibName];
    }
    if (!title) {
        NSString *objClass = [TEALAutotrackDataSources objectClassFor:obj];
        if (objClass) title = objClass;
    }
    
    return title;
}

+ (NSString*) localGMTOffset{
    // return hours offset
    int offset = (int)([[NSTimeZone localTimeZone] secondsFromGMT] / 3600);
    return [NSString stringWithFormat:@"%i", offset];
}

@end
