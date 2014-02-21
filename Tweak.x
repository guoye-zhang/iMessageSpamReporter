#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@protocol CKMessage
@property(readonly, nonatomic) BOOL isOutgoing;
@property(readonly, nonatomic) BOOL isiMessage;
@property(readonly, nonatomic) NSDate *date;
@property(readonly, nonatomic) NSString *address;
@end

@class CKBalloonView;

@protocol CKBalloonViewDelegate
- (BOOL)balloonView:(CKBalloonView *)view canReport:(id)sender;
@end

@interface CKBalloonView
@property(weak, nonatomic) id<CKBalloonViewDelegate> delegate;
@end

@interface CKTranscriptCollectionViewController : UIViewController <MFMailComposeViewControllerDelegate, CKBalloonViewDelegate>
- (id<CKMessage>)messageForBalloonView:(id)view;
@end

%hook CKBalloonView

- (void)showMenu {
    %orig;
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSArray *languageList = @[@"zh-Hans"];
    int num = [languageList indexOfObject:language];
    NSString *title;
    switch (num) {
        case 0:
            title = @"举报";
            break;
        default:
            title = @"Report";
    }
    UIMenuItem *report = [[UIMenuItem alloc] initWithTitle:title action:@selector(report:)];
    NSMutableArray *menuItems = [[UIMenuController sharedMenuController].menuItems mutableCopy];
    [menuItems addObject:report];
    [UIMenuController sharedMenuController].menuItems = menuItems;
    [[UIMenuController sharedMenuController] update];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return %orig(action, sender) || ([self.delegate balloonView:self canReport:sender] && (action == @selector(report:)));
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
        [mc setToRecipients:[NSArray arrayWithObject:@"imessage.spam@icloud.com"]];
        [mc addAttachmentData:screenshot mimeType:@"image/png" fileName:@"screenshot.png"];
        [self presentViewController:mc animated:YES completion:nil];
        [_center removeObserver:_token];
    }];
}

%new
- (BOOL)balloonView:(CKBalloonView *)view canReport:(id)sender {
    id<CKMessage> message = [self messageForBalloonView:view];
    return message.isiMessage && !message.isOutgoing;
}

%new
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

%end
