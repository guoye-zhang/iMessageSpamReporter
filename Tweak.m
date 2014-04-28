#import "Tweak.h"

%hook CKTranscriptCollectionViewController

- (NSArray *)menuItemsForBalloonView:(id)view {
    if ([self shouldShowReportForMessage:[self messageForBalloonView:view]]) {
        NSMutableArray *menuItems = [%orig(view) mutableCopy];
        NSString *title = @{REPORT_DICT}[[[NSLocale preferredLanguages] objectAtIndex:0]];
        if (!title)
            title = REPORT_DEFAULT;
        UIMenuItem *report = [[UIMenuItem alloc] initWithTitle:title action:@selector(report:)];
        [menuItems addObject:report];
        return menuItems;
    } else
        return %orig(view);
}

%new
- (void)balloonView:(id)view report:(id)sender {
    __block id token = [[NSNotificationCenter defaultCenter] addObserverForName:UIMenuControllerDidHideMenuNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        [[NSNotificationCenter defaultCenter] removeObserver:token];
        token = nil;
        MFMailComposeViewController *mc = [MFMailComposeViewController new];
        if (mc) {
            UIImage *_UICreateScreenUIImage();
            UIImage *image = _UICreateScreenUIImage();
            UIInterfaceOrientation orientation = self.interfaceOrientation;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && orientation != UIInterfaceOrientationLandscapeLeft) {
                CGSize size = image.size;
                UIImageOrientation rotate;
                CGFloat height, width;
                if (orientation == UIInterfaceOrientationLandscapeRight) {
                    rotate = UIImageOrientationDown;
                    height = size.height;
                    width = size.width;
                } else {
                    height = size.width;
                    width = size.height;
                    if (orientation == UIInterfaceOrientationPortrait)
                        rotate = UIImageOrientationLeft;
                    else
                        rotate = UIImageOrientationRight;
                }
                UIGraphicsBeginImageContext(CGSizeMake(height, width));
                [[UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:rotate] drawInRect:CGRectMake(0 ,0 ,height ,width)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            NSData *screenshot = UIImagePNGRepresentation(image);
            mc.mailComposeDelegate = self;
            [mc setSubject:@"Spam Report"];
            id<CKMessage> message = [self messageForBalloonView:view];
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm' 'z"];
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            [mc setMessageBody:[NSString stringWithFormat:@"%@\n%@", message.address, [dateFormatter stringFromDate:message.date]] isHTML:NO];
            [mc setToRecipients:@[@"imessage.spam@icloud.com"]];
            [mc addAttachmentData:screenshot mimeType:@"image/png" fileName:@"screenshot.png"];
            [self presentViewController:mc animated:YES completion:nil];
        }
    }];
}

%new
- (BOOL)shouldShowReportForMessage:(id<CKMessage>)message {
    return message.isiMessage && !message.isOutgoing;
}

- (BOOL)balloonView:(id)view canPerformAction:(SEL)action withSender:(id)sender {
    return %orig(view, action, sender) || (action == @selector(balloonView:report:));
}

%new
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

%end
