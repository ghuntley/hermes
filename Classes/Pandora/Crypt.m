//
//  Crypt.m
//  Pithos
//
//  Created by Alex Crichton on 3/11/11.
//  Copyright 2011 Carnegie Mellon University. All rights reserved.
//

#include <math.h>
#include <string.h>
#include <stdlib.h>

#import "Crypt.h"
#import "Keys.h"

#define FETCH(s,i,len) ((i) >= (len) ? 0 : (s)[i])

NSString* PandoraDecrypt(NSString* string) {
  int len, i, j;
  uint32_t l, r, t, a, b, c, d, f;
  const char *hex;
//  unsigned char *cstr;
  char buf[3] = {'\0', '\0', '\0'};

  hex  = [string UTF8String];
  len  = strlen(hex) / 2;
//  cstr = malloc(len);
//  if (cstr == NULL) {
//    return nil;
//  }
  NSMutableData *nsdata = [NSMutableData dataWithLength:len];
  char *data = [nsdata mutableBytes];

  /* Convert the hex string to a list of bytes */
  for (i = 0; i < len; i += 2) {
    buf[0] = hex[i];
    buf[1] = hex[i + 1];
    data[i] = strtol(buf, NULL, 16);
  }

  for (i = 0; i < len / 2; i += 8) {
    l = (FETCH(data, i, len) << 24) |
        (FETCH(data, i + 1, len) << 16) |
        (FETCH(data, i + 2, len) << 8) |
         FETCH(data, i + 3, len);

    r = (FETCH(data, i + 4, len) << 24) |
        (FETCH(data, i + 5, len) << 16) |
        (FETCH(data, i + 6, len) << 8) |
         FETCH(data, i + 7, len);

    for (j = InputKey_n + 1; j > 1; j--) {
      l ^= InputKey_p[j];

      a = (l >> 24) & 0xff;
      b = (l >> 16) & 0xff;
      c = (l >>  8) & 0xff;
      d = (l >>  0) & 0xff;

      f = InputKey_s[0][a] + InputKey_s[1][b];
      f ^= InputKey_s[2][c];
      f += InputKey_s[3][d];
      r ^= f;

      /* Swap l & r */
      t = l;
      l = r;
      r = t;
    }

    t = l;
    l = r;
    r = t;

    r ^= InputKey_p[1];
    l ^= InputKey_p[0];

    sprintf(data + i, "%08x%08x", l, r);
//    l = htonl(l);
//    r = htonl(r);
//    [data appendBytes: &l length: sizeof(l)];
//    [data appendBytes: &r length: sizeof(r)];
  }

//  free(cstr);

  NSString *ret = [[NSString alloc] initWithData:nsdata
    encoding:NSUTF8StringEncoding];

//  [data release];

  NSLogd(@"%@", ret);
  [ret autorelease];

  return ret;
}

NSString* PandoraEncrypt(NSString* string) {
  const char *cstr = [string UTF8String];
  int len, i;
  uint32_t l, r, t, j, a, b, c, d, f;

  len = [string length];
  /* Build the hex encryption in a C string with the correct length allocated */
  NSMutableData *nsdata = [NSMutableData dataWithLength:ceil(len / 8.0) * 16];
  char *data = [nsdata mutableBytes];

  for (i = 0; i < len; i += 8) {
    l = (FETCH(cstr, i, len) << 24) |
        (FETCH(cstr, i + 1, len) << 16) |
        (FETCH(cstr, i + 2, len) << 8) |
         FETCH(cstr, i + 3, len);

    r = (FETCH(cstr, i + 4, len) << 24) |
        (FETCH(cstr, i + 5, len) << 16) |
        (FETCH(cstr, i + 6, len) << 8) |
         FETCH(cstr, i + 7, len);

    for (j = 0; j < OutputKey_n; j++) {
      l ^= OutputKey_p[j];

      a = (l >> 24) & 0xff;
      b = (l >> 16) & 0xff;
      c = (l >>  8) & 0xff;
      d = (l >>  0) & 0xff;

      f = OutputKey_s[0][a] + OutputKey_s[1][b];
      f ^= OutputKey_s[2][c];
      f += OutputKey_s[3][d];
      r ^= f;

      /* Swap l & r */
      t = l;
      l = r;
      r = t;
    }

    t = l;
    l = r;
    r = t;

    r ^= OutputKey_p[OutputKey_n];
    l ^= OutputKey_p[OutputKey_n + 1];

    sprintf(data, "%08x%08x", l, r);
    data += 16;
  }

  NSString *ret = [[NSString alloc] initWithData:nsdata
                                        encoding:NSUTF8StringEncoding];
  [ret autorelease];

  return ret;
}
