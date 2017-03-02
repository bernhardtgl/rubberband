//
//  Base64.h
//  TestSendFile
//
//  Created by Greg (208) 861-9988 on 1/16/09.
//

#import <Foundation/Foundation.h>


@interface NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;
@end

