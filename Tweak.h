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

@protocol CKMessage // iOS 7
@property(readonly, nonatomic) BOOL isOutgoing;
@property(readonly, nonatomic) BOOL isiMessage;
@property(readonly, nonatomic) NSDate *date;
@property(readonly, nonatomic) NSString *address;
@end

@interface IMHandle // iOS 8
@property(readonly, nonatomic) NSString *ID;
@end

@interface IMMessage // iOS 8
@property(readonly, nonatomic) BOOL __ck_isiMessage;
@property(readonly, nonatomic) BOOL isFromMe;
@property(readonly, nonatomic) NSDate *time;
@property(readonly, nonatomic) IMHandle *sender;
@end

@interface CKMessagePartChatItem // iOS 8
@property(readonly, nonatomic) IMMessage *message;
@end

@interface CKTranscriptCollectionViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property(nonatomic) UIViewController *delegate;
- (id<CKMessage>)messageForBalloonView:(id)view; // iOS 7
- (CKMessagePartChatItem *)messagePartForBalloonView:(id)view; // iOS 8
- (void)balloonView:(id)view report:(id)sender; // iOS 8
@end

@interface CKBalloonView // iOS 8
@property(nonatomic) CKTranscriptCollectionViewController *delegate;
@end
