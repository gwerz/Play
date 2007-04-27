/*
 *  $Id$
 *
 *  Copyright (C) 2006 - 2007 Stephen F. Booth <me@sbooth.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import "WavPackMetadataReader.h"
#import "AudioStream.h"
#include <wavpack/wavpack.h>

@implementation WavPackMetadataReader

- (BOOL) readMetadata:(NSError **)error
{
	NSMutableDictionary				*metadataDictionary;
	NSString						*path;
	char							errorMsg [80];
	char							*tagValue;
    WavpackContext					*wpc;
	int								len;

	path							= [[self valueForKey:StreamURLKey] path];

	wpc			= WavpackOpenFileInput([path fileSystemRepresentation], errorMsg, OPEN_TAGS, 0);
	if(NULL == wpc) {
		if(nil != error) {
			NSMutableDictionary *errorDictionary = [NSMutableDictionary dictionary];
			
			[errorDictionary setObject:[NSString stringWithFormat:NSLocalizedStringFromTable(@"The file \"%@\" is not a valid WavPack file.", @"Errors", @""), [[NSFileManager defaultManager] displayNameAtPath:path]] forKey:NSLocalizedDescriptionKey];
			[errorDictionary setObject:NSLocalizedStringFromTable(@"Not a WavPack file", @"Errors", @"") forKey:NSLocalizedFailureReasonErrorKey];
			[errorDictionary setObject:NSLocalizedStringFromTable(@"The file's extension may not match the file's type.", @"Errors", @"") forKey:NSLocalizedRecoverySuggestionErrorKey];						
			
			*error = [NSError errorWithDomain:AudioMetadataReaderErrorDomain 
										 code:AudioMetadataReaderFileFormatNotRecognizedError 
									 userInfo:errorDictionary];
		}
		
		return NO;
	}

	metadataDictionary			= [NSMutableDictionary dictionary];

	// Album title
	len			= WavpackGetTagItem(wpc, "ALBUM", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "ALBUM", tagValue, len + 1);
		[metadataDictionary setValue:[NSString stringWithUTF8String:tagValue] forKey:MetadataAlbumTitleKey];
		free(tagValue);
	}
	
	// Artist
	len			= WavpackGetTagItem(wpc, "ARTIST", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "ARTIST", tagValue, len + 1);
		[metadataDictionary setValue:[NSString stringWithUTF8String:tagValue] forKey:MetadataArtistKey];
		free(tagValue);
	}
	
	// Composer
	len			= WavpackGetTagItem(wpc, "COMPOSER", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "COMPOSER", tagValue, len + 1);
		[metadataDictionary setValue:[NSString stringWithUTF8String:tagValue] forKey:MetadataComposerKey];
		free(tagValue);
	}
	
	// Genre
	len			= WavpackGetTagItem(wpc, "GENRE", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "GENRE", tagValue, len + 1);
		[metadataDictionary setValue:[NSString stringWithUTF8String:tagValue] forKey:MetadataGenreKey];
		free(tagValue);
	}
	
	// Year
	len			= WavpackGetTagItem(wpc, "YEAR", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "YEAR", tagValue, len + 1);
		[metadataDictionary setValue:[NSString stringWithUTF8String:tagValue] forKey:MetadataDateKey];
		free(tagValue);
	}
	
	// Comment
	len			= WavpackGetTagItem(wpc, "COMMENT", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "COMMENT", tagValue, len + 1);
		[metadataDictionary setValue:[NSString stringWithUTF8String:tagValue] forKey:MetadataCommentKey];
		free(tagValue);
	}
	
	// Track title
	len			= WavpackGetTagItem(wpc, "TITLE", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "TITLE", tagValue, len + 1);
		[metadataDictionary setValue:[NSString stringWithUTF8String:tagValue] forKey:MetadataTitleKey];
		free(tagValue);
	}
	
	// Track number
	len			= WavpackGetTagItem(wpc, "TRACK", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "TRACK", tagValue, len + 1);
		[metadataDictionary setValue:[NSNumber numberWithInt:[[NSString stringWithUTF8String:tagValue] intValue]] forKey:MetadataTrackNumberKey];
		free(tagValue);
	}
	
	// Total tracks
	len			= WavpackGetTagItem(wpc, "TRACKTOTAL", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "TRACKTOTAL", tagValue, len + 1);
		[metadataDictionary setValue:[NSNumber numberWithInt:[[NSString stringWithUTF8String:tagValue] intValue]] forKey:MetadataTrackTotalKey];
		free(tagValue);
	}
	
	// Disc number
	len			= WavpackGetTagItem(wpc, "DISCNUMBER", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "DISCNUMBER", tagValue, len + 1);
		[metadataDictionary setValue:[NSNumber numberWithInt:[[NSString stringWithUTF8String:tagValue] intValue]] forKey:MetadataDiscNumberKey];
		free(tagValue);
	}
	
	// Discs in set
	len			= WavpackGetTagItem(wpc, "DISCTOTAL", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "DISCTOTAL", tagValue, len + 1);
		[metadataDictionary setValue:[NSNumber numberWithInt:[[NSString stringWithUTF8String:tagValue] intValue]] forKey:MetadataAlbumTitleKey];
		free(tagValue);
	}
	
	// Compilation
	len			= WavpackGetTagItem(wpc, "COMPILATION", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "COMPILATION", tagValue, len + 1);
		[metadataDictionary setValue:[NSNumber numberWithBool:(BOOL)[[NSString stringWithUTF8String:tagValue] intValue]] forKey:MetadataCompilationKey];
		free(tagValue);
	}
	
	// MCN
	len			= WavpackGetTagItem(wpc, "MCN", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "MCN", tagValue, len + 1);
		[metadataDictionary setValue:[NSString stringWithUTF8String:tagValue] forKey:MetadataMCNKey];
		free(tagValue);
	}
	
	// ISRC
	len			= WavpackGetTagItem(wpc, "ISRC", NULL, 0);
	if(0 != len) {
		tagValue = (char *)calloc(len + 1, sizeof(char));
		NSAssert(NULL != tagValue, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Errors", @""));
		
		WavpackGetTagItem(wpc, "ISRC", tagValue, len + 1);
		[metadataDictionary setValue:[NSString stringWithUTF8String:tagValue] forKey:MetadataISRCKey];
		free(tagValue);
	}
	
	WavpackCloseFile(wpc);
	
	[self setValue:metadataDictionary forKey:@"metadata"];
	
	return YES;
}

@end
