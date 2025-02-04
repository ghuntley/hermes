#include <libxml/parser.h>

#pragma once

#define PANDORA_API_HOST @"www.pandora.com"
#define PANDORA_API_PATH @"/radio/xmlrpc/"
#define PANDORA_API_VERSION @"v32"

@interface PandoraRequest : NSObject {
  @private
  SEL callback;
  NSObject *info;
  NSString *requestData;
  NSString *requestMethod;
  NSMutableData *responseData;
}

@property (retain) NSString *requestData;
@property (retain) NSString *requestMethod;
@property (retain) NSMutableData *responseData;
@property (retain) NSObject *info;
@property (readwrite) SEL callback;

+ (PandoraRequest*) requestWithMethod: (NSString*) requestMethod
                                 data: (NSString*) data
                             callback: (SEL) callback
                                 info: (NSObject*) info;
- (void) resetResponse;
- (void) replaceAuthToken:(NSString*) token with:(NSString*) replacement;
@end

BOOL xpathNodes(xmlDocPtr doc, char* xpath, void (^callback)(xmlNodePtr));
NSString *xpathRelative(xmlDocPtr doc, char* xpath, xmlNodePtr node);

@interface API : NSObject {
  NSString *listenerID;

  NSMutableDictionary *activeRequests;
}

@property (retain) NSString* listenerID;

- (int) time;
- (BOOL) sendRequest: (PandoraRequest*) request;

@end
