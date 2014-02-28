#define REPORT_DICT \
@"zh-Hans": @"举报…",\
@"zh-Hant": @"檢舉…",\
@"fr": @"Rapport…",\
@"de": @"Bericht…",\
@"ja": @"レポート…",\
@"nl": @"Verslag…",\
@"it": @"Rapporto…",\
@"es": @"Informe…",\
@"es-MX": @"Informe…",\
@"pt": @"Relatório…",\
@"pt-PT": @"Relatório…",\
@"da": @"Rapport…",\
@"fi": @"Raportti…",\
@"nb": @"Rapporter…",\
@"sv": @"Rapportera…",\
@"ko": @"보고서…",\
@"ru": @"Отчет…",\
@"pl": @"Raport…",\
@"tr": @"Rapor…",\
@"uk": @"Звіт…",\
@"ar": @"تقرير…",\
@"hr": @"Izvješće…",\
@"cs": @"Zpráva…",\
@"el": @"Έκθεση…",\
@"he": @"דווח…",\
@"ro": @"Raport…",\
@"sk": @"Správa…",\
@"th": @"รายงาน…",\
@"id": @"Laporan…",\
@"ms": @"Laporan…",\
@"ca": @"Informe…",\
@"hu": @"Jelentés…",\
@"vi": @"Báo cáo…"

#define REPORT_DEFAULT @"Report…"

#import <MessageUI/MessageUI.h>

@protocol CKMessage
@property(readonly, nonatomic) BOOL isOutgoing;
@property(readonly, nonatomic) BOOL isiMessage;
@property(readonly, nonatomic) NSDate *date;
@property(readonly, nonatomic) NSString *address;
@end

@interface CKTranscriptCollectionViewController : UIViewController <MFMailComposeViewControllerDelegate>
- (id<CKMessage>)messageForBalloonView:(id)view;
- (BOOL)shouldShowReportForMessage:(id<CKMessage>)message;
@end

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
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    id _center = center;
    __block id _token = [center addObserverForName:UIMenuControllerDidHideMenuNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        [_center removeObserver:_token];
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
