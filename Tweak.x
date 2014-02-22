#define REPORT_DICT \
@"zh-Hans": @"举报"

#import <MessageUI/MessageUI.h>

@protocol CKMessage
@property(readonly, nonatomic) BOOL isOutgoing;
@property(readonly, nonatomic) BOOL isiMessage;
@property(readonly, nonatomic) NSDate *date;
@property(readonly, nonatomic) NSString *address;
@end

@class CKBalloonView;

@interface CKTranscriptCollectionViewController : UIViewController <MFMailComposeViewControllerDelegate>
- (id<CKMessage>)messageForBalloonView:(CKBalloonView *)view;
- (BOOL)shouldShowReportForMessage:(id<CKMessage>)message;
@end

%hook CKBalloonView

- (void)showMenu {
    %orig;
    NSString *title = @{REPORT_DICT}[[[NSLocale preferredLanguages] objectAtIndex:0]];
    if (!title)
        title = @"Report";
    UIMenuItem *report = [[UIMenuItem alloc] initWithTitle:title action:@selector(report:)];
    NSMutableArray *menuItems = [[UIMenuController sharedMenuController].menuItems mutableCopy];
    [menuItems addObject:report];
    [UIMenuController sharedMenuController].menuItems = menuItems;
    [[UIMenuController sharedMenuController] update];
}

%end

%hook CKTranscriptCollectionViewController

%new
- (void)balloonView:(CKBalloonView *)view report:(id)sender {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    id _center = center;
    __block id _token = [center addObserverForName:UIMenuControllerDidHideMenuNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        UIImage *_UICreateScreenUIImage();
        NSData *screenshot = UIImagePNGRepresentation(_UICreateScreenUIImage());
        MFMailComposeViewController *mc = [MFMailComposeViewController new];
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
        [_center removeObserver:_token];
    }];
}

%new
- (BOOL)shouldShowReportForMessage:(id<CKMessage>)message {
    return message.isiMessage && !message.isOutgoing;
}

- (BOOL)balloonView:(CKBalloonView *)view canPerformAction:(SEL)action withSender:(id)sender {
    return %orig(view, action, sender) || ((action == @selector(balloonView:report:)) && [self shouldShowReportForMessage:[self messageForBalloonView:view]]);
}

%new
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

%end
