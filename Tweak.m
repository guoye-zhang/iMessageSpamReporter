#import "Tweak.h"

%hook CKTranscriptCollectionViewController

- (NSArray *)menuItemsForBalloonView:(id)view {
    BOOL shouldShow;
    if ([self respondsToSelector:@selector(messageForBalloonView:)]) {
        id<CKMessage> message = [self messageForBalloonView:view];
        shouldShow = message.isiMessage && !message.isOutgoing;
    } else {
        IMMessage *message = [self messagePartForBalloonView:view].message;
        shouldShow = message.__ck_isiMessage && !message.isFromMe;
    }
    if (shouldShow) {
        NSMutableArray *menuItems = [%orig mutableCopy];
        NSString *title = @{REPORT_DICT}[[[NSLocale preferredLanguages] objectAtIndex:0]];
        if (!title)
            title = REPORT_DEFAULT;
        UIMenuItem *report = [[UIMenuItem alloc] initWithTitle:title action:@selector(report:)];
        [menuItems addObject:report];
        return menuItems;
    } else
        return %orig;
}

%new
- (void)balloonView:(id)view report:(id)sender {
    __block id token = [[NSNotificationCenter defaultCenter] addObserverForName:UIMenuControllerDidHideMenuNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        [[NSNotificationCenter defaultCenter] removeObserver:token];
        token = nil;
        MFMailComposeViewController *mc = [MFMailComposeViewController new];
        if (mc) {
            UIWindow *window = self.view.window;
            UIView *view = [[UIApplication sharedApplication] valueForKey:@"_statusBarWindow"];
            UIGraphicsBeginImageContext(view.bounds.size);
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
            [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSData *screenshot = UIImagePNGRepresentation(image);
            
            NSDate *date;
            NSString *address;
            if ([self respondsToSelector:@selector(messageForBalloonView:)]) {
                id<CKMessage> message = [self messageForBalloonView:view];
                date = message.date;
                address = message.address;
            } else {
                IMMessage *message = [self messagePartForBalloonView:view].message;
                date = message.time;
                address = message.sender.ID;
            }
            
            mc.mailComposeDelegate = self;
            [mc setSubject:@"Spam Report"];
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm' 'z"];
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            [mc setMessageBody:[NSString stringWithFormat:@"%@\n%@", address, [dateFormatter stringFromDate:date]] isHTML:NO];
            [mc setToRecipients:@[@"imessage.spam@icloud.com"]];
            [mc addAttachmentData:screenshot mimeType:@"image/png" fileName:@"screenshot.png"];
            [self presentViewController:mc animated:YES completion:nil];
        }
    }];
}

- (BOOL)balloonView:(id)view canPerformAction:(SEL)action withSender:(id)sender {
    return %orig || (action == @selector(balloonView:report:)) /* iOS 7 */ || (action == @selector(report:)) /* iOS 8 */;
}

%new
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

%end


%hook CKBalloonView // iOS 8

%new
- (void)report:(id)sender {
    [self.delegate balloonView:self report:sender];
}

%end
