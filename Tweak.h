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
