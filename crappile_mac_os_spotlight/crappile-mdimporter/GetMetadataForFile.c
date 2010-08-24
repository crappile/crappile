#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h> 

/* -----------------------------------------------------------------------------
   Step 1
   Set the UTI types the importer supports
  
   Modify the CFBundleDocumentTypes entry in Info.plist to contain
   an array of Uniform Type Identifiers (UTI) for the LSItemContentTypes 
   that your importer can handle
  
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 2 
   Implement the GetMetadataForFile function
  
   Implement the GetMetadataForFile function below to scrape the relevant
   metadata from your document and return it as a CFDictionary using standard keys
   (defined in MDItem.h) whenever possible.
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 3 (optional) 
   If you have defined new attributes, update the schema.xml file
  
   Edit the schema.xml file to include the metadata keys that your importer returns.
   Add them to the <allattrs> and <displayattrs> elements.
  
   Add any custom types that your importer requires to the <attributes> element
  
   <attribute name="com_mycompany_metadatakey" type="CFString" multivalued="true"/>
  
   ----------------------------------------------------------------------------- */



/* -----------------------------------------------------------------------------
    Get metadata attributes from file
   
   This function's job is to extract useful information your file format supports
   and return it as a dictionary
   ----------------------------------------------------------------------------- */

Boolean GetMetadataForFile(void* thisInterface, 
			   CFMutableDictionaryRef attributes, 
			   CFStringRef contentTypeUTI,
			   CFStringRef pathToFile)
{
    /* Pull any available metadata from the file at the specified path */
    /* Return the attribute keys and attribute values in the dict */
    /* Return TRUE if successful, FALSE if there was no data provided */
	
	const char *bytes;

	bytes = CFStringGetCStringPtr(pathToFile, kCFStringEncodingMacRoman);
	
	FILE *fp;
	fp=fopen(bytes, "r");
	
	if ( fp )
	{
		static const int BUFFER_SIZE = 1000;
		char buffer[BUFFER_SIZE];
		buffer[0] = '\0';
		
		while (!feof(fp))
		{
			int sizeOfString = strlen(buffer);
			int maxToRead = BUFFER_SIZE - sizeOfString - 1;
			
			fgets( (&(buffer[sizeOfString])),maxToRead,fp);
		}	
		
		if ( strlen(buffer) > 0 )
		{
			CFStringRef tagValue = CFStringCreateWithBytes (
															kCFAllocatorDefault
															, (unsigned char*) buffer 
															, strlen(buffer)
															, kCFStringEncodingASCII
															, false //Boolean isExternalRepresentation
															);
			
			CFDictionarySetValue(attributes, CFSTR("kMDItemFinderComment"), tagValue);
			CFDictionarySetValue(attributes, CFSTR("kMDItemTextContent"), tagValue);			
			
			CFRelease( tagValue );
		}
		
		fclose(fp);
		return TRUE;
	}
	else
	{
		fclose(fp);
		return FALSE;
	}
}
