#ifndef __VNTTS_H__
#define __VNTTS_H__


#include "vntts.h"

#ifdef __cplusplus
extern "C"
{
#endif

#define DWORD	unsigned int
#define WORD unsigned short

#define		wchar_t		char
#define		wcslen		strlen
#define		wcscpy		strcpy
#define		wcsncpy		strncpy
#define		wcscmp		strcmp
#define		wcsrev		strrev
#define		wcsncat		strncat
#define		wcschr		strchr
#define		mbstowcs 	strcpy
#define		wcstombs 	strcpy
#define		wcscat		strcat
#define		wsprintf		sprintf

#define		_wtoi		atoi
#define		_wtol		atol
#define		_ltow		ltoa
#define		_itow		itoa
#define		__int8		char
#define		__int16		short
#define		__int32		int
#define		__int64		long long
#define		_isnan		isnan		
#define		_strupr		strupr
#define		_ultoa		ultoa
#define		_ltoa			ltoa		

#define		_tcscpy            strcpy
#define		wcstol		strtol
#define		_wcsnicmp	strncasecmp
#define		iswspace		isspace
#define		TCHAR		char
#define		_wfopen		fopen
#define		_T(x)	x

typedef struct {
	WORD  wFormatTag;
	WORD  nChannels;
	DWORD nSamplesPerSec;
	DWORD nAvgBytesPerSec;
	WORD  nBlockAlign;
	WORD  wBitsPerSample;
	WORD  cbSize;
}WAVEFORMATEX;

//char* g_lpszVNTTSDataPath = NULL;


__int16* LoadWave16Bit44100Hz(char *lpszFileName,__int32& dwSamps)
{
	FILE* f = NULL;
	char szTmp[10];
	WAVEFORMATEX pcmWaveFormat;
	DWORD dwFileSize = 0;
	DWORD dwFmtSize = 0;
	DWORD dwNum = 0;
	f = fopen(lpszFileName,"rb");
	if (!f)
		return NULL;

	//ZeroMemory(szTmp, 10 * sizeof(char));
	for (int i=0; i<10; i++) {
		szTmp[i] = 0;
	}
	
	fread(szTmp,4,1,f);
	if (strncmp(szTmp, "RIFF", 4) != 0) 
		return  NULL;

	fread(&dwFileSize,1,sizeof(dwFileSize),f);
	fread(&szTmp,8,1,f);
	if (strncmp(szTmp, "WAVEfmt ", 8) != 0) 
		return NULL;

	fread(&dwFmtSize,sizeof(dwFmtSize),1,f);
	fread(&pcmWaveFormat.wFormatTag,1,sizeof(pcmWaveFormat.wFormatTag),f);
	fread(&pcmWaveFormat.nChannels,1,sizeof(pcmWaveFormat.nChannels),f);
	fread(&pcmWaveFormat.nSamplesPerSec,1,sizeof(pcmWaveFormat.nSamplesPerSec),f);
	fread(&pcmWaveFormat.nAvgBytesPerSec,1,sizeof(pcmWaveFormat.nAvgBytesPerSec),f);
	fread(&pcmWaveFormat.nBlockAlign,1,sizeof(pcmWaveFormat.nBlockAlign),f);
	fread(&pcmWaveFormat.wBitsPerSample,1,sizeof(pcmWaveFormat.wBitsPerSample),f);
	//ZeroMemory(szTmp, 10 * sizeof(char));
	for (int i=0; i<10; i++) {
		szTmp[i] = 0;
	}
	fread(szTmp,4,1,f);
	if (strncmp(szTmp, "data", 4) != 0) 
		return NULL;

	fread(&dwNum,1,sizeof(dwNum),f);
	dwSamps = dwNum / pcmWaveFormat.nBlockAlign;///dwSamps: toc do lay mau

	__int16* pData = (__int16*)calloc(dwSamps,sizeof(__int16));
	fread(pData,dwSamps,sizeof(__int16),f);
	fclose(f);
	return pData;
}

void SaveWave16Bit44100Hz(char *lpszFileName,__int16* pData, __int32 dwSamps, int nVolume)
{
	FILE* f = fopen(lpszFileName,"wb");
///dwSamps: tong so mau cua file am thanh
	char szTmp[10];
	WAVEFORMATEX pcmWaveFormat;
	DWORD dwFileSize = 11 + dwSamps * sizeof(__int16);///44->11
	DWORD dwFmtSize = 16;
	DWORD dwNum = dwSamps * 2;

	strcpy(szTmp,"RIFF");
	fwrite(szTmp,4,1,f);
	fwrite(&dwFileSize,1,sizeof(dwFileSize),f);
	strcpy(szTmp,"WAVEfmt ");
	fwrite(&szTmp,8,1,f);
	fwrite(&dwFmtSize,sizeof(dwFmtSize),1,f);
	
	pcmWaveFormat.cbSize = sizeof(WAVEFORMATEX);
	pcmWaveFormat.nChannels = 1;
	pcmWaveFormat.nSamplesPerSec = 11025;///44100->11025
	pcmWaveFormat.wBitsPerSample = 16;
	pcmWaveFormat.wFormatTag = 1;
	pcmWaveFormat.nBlockAlign = 2;
	pcmWaveFormat.nAvgBytesPerSec = 11025 * 2;///44100->11025
	
	fwrite(&pcmWaveFormat.wFormatTag,1,sizeof(pcmWaveFormat.wFormatTag),f);
	fwrite(&pcmWaveFormat.nChannels,1,sizeof(pcmWaveFormat.nChannels),f);
	fwrite(&pcmWaveFormat.nSamplesPerSec,1,sizeof(pcmWaveFormat.nSamplesPerSec),f);
	fwrite(&pcmWaveFormat.nAvgBytesPerSec,1,sizeof(pcmWaveFormat.nAvgBytesPerSec),f);
	fwrite(&pcmWaveFormat.nBlockAlign,1,sizeof(pcmWaveFormat.nBlockAlign),f);
	fwrite(&pcmWaveFormat.wBitsPerSample,1,sizeof(pcmWaveFormat.wBitsPerSample),f);
	strcpy(szTmp,"data");
	fwrite(szTmp,4,1,f);
	fwrite(&dwNum,1,sizeof(dwNum),f);
	
	if (nVolume > 1 && nVolume <= 7)
	{
		long iTempNew;
		long i=0;
		for (i = 0; i < dwSamps; i ++)
		{
			iTempNew = pData[i];
			iTempNew *=  nVolume;
			
			if (iTempNew>32767){
				iTempNew = 32767;
			}
			else{
				if (iTempNew<-32768){
					iTempNew = -32768;
				}
			}
			
			pData[i] = (short) iTempNew;
		}
		
	}
	
	
	fwrite(pData,dwSamps,sizeof(__int16),f);
	fclose(f);
}

__int16* DiphConcat(char* lpszF1,char* lpszF2, __int32& sampnum)
{
	char* lpszFile1Pim = (char*)calloc(1024,1);
	char* lpszFile2Pim = (char*)calloc(1024,1);
	char* lpszFile1Wav = (char*)calloc(1024,1);
	char* lpszFile2Wav = (char*)calloc(1024,1);
	FILE* f = NULL;
	__int16* buf1 = NULL;
	__int16* buf2 = NULL;
	__int16* buf = NULL;
	__int32 num1 = 0;
	__int32 num2 = 0;
	__int16 st1 = 0;///st1: start cua doan file pim1
	__int16 ed1 = 0;/// ed1: end cua doan file pim1
	__int16 st2 = 0;
	__int16 ed2 = 0;
	 
	__int16 s1 = 0;
	__int16 e1 = 0;
	__int16 s2 = 0;
	__int16 e2 = 0;

	int i = 0;
	double pw1 = 0;
	double pw2 = 0;
	double factor = 0;

	strcpy(lpszFile1Pim,g_lpszVNTTSDataPath);
	strcat(lpszFile1Pim,"_");
	strcat(lpszFile1Pim,lpszF1);
	strcat(lpszFile1Pim,".pim");
	
	strcpy(lpszFile2Pim,g_lpszVNTTSDataPath);
	strcat(lpszFile2Pim,lpszF2);
	strcat(lpszFile2Pim,".pim");

	strcpy(lpszFile1Wav,g_lpszVNTTSDataPath);
	strcat(lpszFile1Wav,"_");
	strcat(lpszFile1Wav,lpszF1);
	strcat(lpszFile1Wav,".wav");
	
	strcpy(lpszFile2Wav,g_lpszVNTTSDataPath);
	strcat(lpszFile2Wav,lpszF2);
	strcat(lpszFile2Wav,".wav");
	
	f = fopen(lpszFile1Pim,"rb");
	if (!f)
		return NULL;
	fread(&st1,1,2,f);
	fread(&ed1,1,2,f);
	fclose(f);
	
	f = fopen(lpszFile2Pim,"rb");
	if (!f)
		return NULL;
	fread(&st2,1,2,f);
	fread(&ed2,1,2,f);
	fclose(f);
	///----------
	s1=st1/4; e1=ed1/4;
	s2=st2/4; e2=ed2/4;
	///-----------
	buf1 = LoadWave16Bit44100Hz(lpszFile1Wav,num1);
	if (!buf1)
		return NULL;
	buf2 = LoadWave16Bit44100Hz(lpszFile2Wav,num2);
	if (!buf2)
		return NULL;

	buf = (__int16*)calloc(num1+num2,sizeof(__int16));

	for (i = s1;i <= e1;i++) /// thay st1=s1; ed1=e1
	{
		pw1 += (double)buf1[i] * (double)buf1[i];
	}
	pw1 /= (double)(e1 - s1 + 1);

	for (i = s2;i <= e2;i++) ///thay st2=s2; ed2=e2
	{
		pw2 += (double)buf2[i] * (double)buf2[i];
	}
	pw2 /= (double)(e2 - s2 + 1);///pw2 nang luong cua file pim2

	//Can bang nang luong
	factor = sqrt(pw1/pw2);
	//fix truong hop factor~0 gay ra loi am thanh ~0 by ldtien 
//	if(factor > 0.7){
//		
//	}else{
//		factor = 0.7;
//	}
	for (i = 0;i < num2;i++)
	{
		buf2[i] *= factor;
	}
	
	
	//Ghep am
	memcpy(buf,buf1,e1*2);
	memcpy(buf+e1,buf2+s2,(num2-s2)*2);
	sampnum = e1 + num2 - s2;

	free(buf1);
	free(buf2);
	free(lpszFile1Pim);
	free(lpszFile2Pim);
	free(lpszFile1Wav);
	free(lpszFile2Wav);

	return buf;
}

char* GetWord(char lpszWord[],char* lpszText)
{
	int pos = 0;
	int start = 0;
	//Cat dau trang o dau chuoi
	while ((pos < strlen(lpszText))&&(lpszText[pos] <= 32))
		pos += 1;
	if (pos == strlen(lpszText))
		return NULL;
	start = pos;
	//Duyet qua mot tu
	while ((pos < strlen(lpszText))&&(lpszText[pos] > 32))
		pos += 1;
	strncpy(lpszWord,lpszText+start,pos-start);
	
	if (pos < strlen(lpszText))
		return (lpszText+pos);
	else
		return NULL;
}

int GetDiphones(char lpszWord[], char lpszD1[], char lpszD2[])
{
	int pos = 0;
	int a = 0; //Co tim duoc nguyen am hay khong
	//Tim nguyen am dau tien
	for (pos = 0;pos < strlen(lpszWord);pos++)
	{
		a = 0;
		switch (lpszWord[pos])
		{
			case 'a':
			case 'A':
			case 'e':
			case 'o':
			case 'y':
				a = 1;
			case 'u':
				if ((pos == 0) || (lpszWord[pos-1] != 'q'))
					a = 1;
				else
				{
					//qu xxx
					if ((pos < strlen(lpszWord)) && ((lpszWord[pos+1] == 'o') || (lpszWord[pos+1] == 'y')))
						a = 1;
				}
			break;
			case 'i':
				if ((pos == 0) || (lpszWord[pos-1] != 'g'))
					a = 1;
				else
				{
					if (pos < strlen(lpszWord))
					{
						switch (lpszWord[pos+1])
						{
							case 'a':
							case 'e':
							case 'o':
							case 'y':
							case 'u':
							break;
							default:
								a = 1;
						}
					}
				}
			break;
		}
		if (a)
			break;
	}

	if (!a) //Du lieu sai, khong co tu nao ma khong chua nguyen am
		return 0;

	//Kiem tra xem co phai nguyen am tieng viet: aw, aa, ee, ow, oo, uw
	if (pos < strlen(lpszWord))
	{
		switch (lpszWord[pos+1])
		{
			case 'e':
			case 'o':
				if (lpszWord[pos] == lpszWord[pos+1])
				{
					memcpy(lpszD1,lpszWord,pos+2);
					memcpy(lpszD2,lpszWord+pos,strlen(lpszWord)-pos);
				}else
				{
					memcpy(lpszD1,lpszWord,pos+1);
					memcpy(lpszD2,lpszWord+pos,strlen(lpszWord)-pos);
				}
			break;
			case 'a':
				if (lpszWord[pos] == lpszWord[pos+1])
				{
					memcpy(lpszD1,lpszWord,pos);
					strcat(lpszD1,"ow");
					memcpy(lpszD2,lpszWord+pos,strlen(lpszWord)-pos);
				}else
				{
					memcpy(lpszD1,lpszWord,pos+1);
					memcpy(lpszD2,lpszWord+pos,strlen(lpszWord)-pos);
				}
			break;
			case 'w':
				if (lpszWord[pos] == 'a')
				{
					memcpy(lpszD1,lpszWord,pos+1);
					memcpy(lpszD2,lpszWord+pos,strlen(lpszWord)-pos);
				}else
				{
					memcpy(lpszD1,lpszWord,pos+2);
					memcpy(lpszD2,lpszWord+pos,strlen(lpszWord)-pos);
				}
			break;
			default:
				memcpy(lpszD1,lpszWord,pos+1);
				memcpy(lpszD2,lpszWord+pos,strlen(lpszWord)-pos);
		}
	}else
	{
		memcpy(lpszD1,lpszWord,pos+1);
		memcpy(lpszD2,lpszWord+pos,1);
	}
	return 1;
}

char* convertToTelexInput(NSString* str){
	NSString* c = nil;
	char mark =0;
	NSString* strInput = [str lowercaseString];
	size_t size = ([strInput length]*3+3)*sizeof(char);
	char* cout = (char*)malloc(size);
	memset(cout, 0, size);
	size_t count =0;
	for (NSUInteger i=0; i<[strInput length]; i++) {
		c = [strInput substringWithRange:NSMakeRange(i, 1)];
			if([c isEqualToString:@"á"] || [c isEqualToString:@"Á"]){
				cout[count++] = 'a';
				mark = 's';
			
			}else
			if([c isEqualToString:@"à"] || [c isEqualToString:@"À"]){
				cout[count++] = 'a';
				mark = 'f';
			}else
			if([c isEqualToString:@"ạ"] || [c isEqualToString:@"Ạ"]){
				cout[count++] = 'a';
				mark = 'j';
			}else
			if([c isEqualToString:@"ả"] || [c isEqualToString:@"Ả"]){
				cout[count++] = 'a';
				mark = 'r';
			}else
			if([c isEqualToString:@"ã"] || [c isEqualToString:@"Ã"]){
				cout[count++] = 'a';
				mark = 'x';
			}else
			if([c isEqualToString:@"ă"] || [c isEqualToString:@"Ă"]){
				cout[count++] = 'a';
				cout[count++] = 'w';
				mark = 0;
			}else
			if([c isEqualToString:@"ắ"] || [c isEqualToString:@"Ắ"]){
				cout[count++] = 'a';
				cout[count++] = 'w';
				mark = 's';
			}else
			if([c isEqualToString:@"ằ"] || [c isEqualToString:@"Ằ"]){
				cout[count++] = 'a';
				cout[count++] = 'w';
				mark = 'f';
			}else
			if([c isEqualToString:@"ặ"] || [c isEqualToString:@"Ặ"]){
				cout[count++] = 'a';
				cout[count++] = 'w';
				mark = 'j';
			}else
			if([c isEqualToString:@"ẳ"] || [c isEqualToString:@"Ẳ"]){
				cout[count++] = 'a';
				cout[count++] = 'w';
				mark = 'r';
			}else
			if([c isEqualToString:@"ẵ"] || [c isEqualToString:@"Ẵ"]){
				cout[count++] = 'a';
				cout[count++] = 'w';
				mark = 'x';
			}else
			if([c isEqualToString:@"â"] || [c isEqualToString:@"Â"]){
				cout[count++] = 'a';
				cout[count++] = 'a';
				mark = 0;
			}else
			if([c isEqualToString:@"ấ"] || [c isEqualToString:@"Ấ"]){
				cout[count++] = 'a';
				cout[count++] = 'a';
				mark = 's';
			}else
			if([c isEqualToString:@"ầ"] || [c isEqualToString:@"Ầ"]){
				cout[count++] = 'a';
				cout[count++] = 'a';
				mark = 'f';
			}else
			if([c isEqualToString:@"ậ"] || [c isEqualToString:@"Ậ"]){
				cout[count++] = 'a';
				cout[count++] = 'a';
				mark = 'j';
			}else
			if([c isEqualToString:@"ẩ"] || [c isEqualToString:@"Ẩ"]){
				cout[count++] = 'a';
				cout[count++] = 'a';
				mark = 'r';
			}else
			if([c isEqualToString:@"ẫ"] || [c isEqualToString:@"Ẫ"]){
				cout[count++] = 'a';
				cout[count++] = 'a';
				mark = 'x';
			}else
			if([c isEqualToString:@"đ"] || [c isEqualToString:@"Đ"]){
				cout[count++] = 'd';
				cout[count++] = 'd';
				mark = 0;
			}else
			if([c isEqualToString:@"ê"] || [c isEqualToString:@"Ê"]){
				cout[count++] = 'e';
				cout[count++] = 'e';
				mark = 0;
			}else
			if([c isEqualToString:@"ế"] || [c isEqualToString:@"Ế"]){
				cout[count++] = 'e';
				cout[count++] = 'e';
				mark = 's';
			}else
			if([c isEqualToString:@"ề"] || [c isEqualToString:@"Ề"]){
				cout[count++] = 'e';
				cout[count++] = 'e';
				mark = 'f';
			}else
			if([c isEqualToString:@"ệ"] || [c isEqualToString:@"Ệ"]){
				cout[count++] = 'e';
				cout[count++] = 'e';
				mark = 'j';
			}else
			if([c isEqualToString:@"ể"] || [c isEqualToString:@"Ể"]){
				cout[count++] = 'e';
				cout[count++] = 'e';
				mark = 'r';
			}else
			if([c isEqualToString:@"ễ"] || [c isEqualToString:@"Ễ"]){
				cout[count++] = 'e';
				cout[count++] = 'e';
				mark = 'x';
			}else
			if([c isEqualToString:@"é"] || [c isEqualToString:@"É"]){
				cout[count++] = 'e';
				mark = 's';
			}else
			if([c isEqualToString:@"è"] || [c isEqualToString:@"È"]){
				cout[count++] = 'e';
				mark = 'f';
			}else
			if([c isEqualToString:@"ẹ"] || [c isEqualToString:@"Ẹ"]){
				cout[count++] = 'e';
				mark = 'j';
			}else
			if([c isEqualToString:@"ẻ"] || [c isEqualToString:@"Ẻ"]){
				cout[count++] = 'e';
				mark = 'r';
			}else
			if([c isEqualToString:@"ẽ"] || [c isEqualToString:@"Ẽ"]){
				cout[count++] = 'e';
				mark = 'x';
			}else
			if([c isEqualToString:@"í"] || [c isEqualToString:@"Í"]){
				cout[count++] = 'i';
				mark = 's';
			}else
			if([c isEqualToString:@"ì"] || [c isEqualToString:@"Ì"]){
				cout[count++] = 'i';
				mark = 'f';
			}else
			if([c isEqualToString:@"ị"] || [c isEqualToString:@"Ị"]){
				cout[count++] = 'i';
				mark = 'j';
			}else
			if([c isEqualToString:@"ỉ"] || [c isEqualToString:@"Ỉ"]){
				cout[count++] = 'i';
				mark = 'r';
			}else
			if([c isEqualToString:@"ĩ"] || [c isEqualToString:@"Ĩ"]){
				cout[count++] = 'i';
				mark = 'x';
			}else
			if([c isEqualToString:@"ó"] || [c isEqualToString:@"Ó"]){
				cout[count++] = 'o';
				mark = 's';
			}else
			if([c isEqualToString:@"ò"] || [c isEqualToString:@"Ò"]){
				cout[count++] = 'o';
				mark = 'f';
			}else
			if([c isEqualToString:@"ọ"] || [c isEqualToString:@"Ọ"]){
				cout[count++] = 'o';
				mark = 'j';
			}else
			if([c isEqualToString:@"ỏ"] || [c isEqualToString:@"Ỏ"]){
				cout[count++] = 'o';
				mark = 'r';
			}else
			if([c isEqualToString:@"õ"] || [c isEqualToString:@"Õ"]){
				cout[count++] = 'o';
				mark = 'x';
			}else
			if([c isEqualToString:@"ô"] || [c isEqualToString:@"Ô"]){
				cout[count++] = 'o';
				cout[count++] = 'o';
				mark = 0;
			}else
			if([c isEqualToString:@"ố"] || [c isEqualToString:@"Ố"]){
				cout[count++] = 'o';
				cout[count++] = 'o';
				mark = 's';
			}else
			if([c isEqualToString:@"ồ"] || [c isEqualToString:@"Ồ"]){
				cout[count++] = 'o';
				cout[count++] = 'o';
				mark = 'f';
			}else
			if([c isEqualToString:@"ộ"] || [c isEqualToString:@"Ộ"]){
				cout[count++] = 'o';
				cout[count++] = 'o';
				mark = 'j';
			}else
			if([c isEqualToString:@"ổ"] || [c isEqualToString:@"Ổ"]){
				cout[count++] = 'o';
				cout[count++] = 'o';
				mark = 'r';
			}else
			if([c isEqualToString:@"ỗ"] || [c isEqualToString:@"Ỗ"]){
				cout[count++] = 'o';
				cout[count++] = 'o';
				mark = 'x';
			}else
			if([c isEqualToString:@"ơ"] || [c isEqualToString:@"Ơ"]){
				cout[count++] = 'o';
				cout[count++] = 'w';
				mark = 0;
			}else
			if([c isEqualToString:@"ớ"] || [c isEqualToString:@"Ớ"]){
				cout[count++] = 'o';
				cout[count++] = 'w';
				mark = 's';
			}else
			if([c isEqualToString:@"ờ"] || [c isEqualToString:@"Ờ"]){
				cout[count++] = 'o';
				cout[count++] = 'w';
				mark = 'f';
			}else
			if([c isEqualToString:@"ợ"] || [c isEqualToString:@"Ợ"]){
				cout[count++] = 'o';
				cout[count++] = 'w';
				mark = 'j';
			}else
			if([c isEqualToString:@"ở"] || [c isEqualToString:@"Ở"]){
				cout[count++] = 'o';
				cout[count++] = 'w';
				mark = 'r';
			}else
			if([c isEqualToString:@"ỡ"] || [c isEqualToString:@"Ỡ"]){
				cout[count++] = 'o';
				cout[count++] = 'w';
				mark = 'x';
			}else
			if([c isEqualToString:@"ú"] || [c isEqualToString:@"Ú"]){
				cout[count++] = 'u';
				mark = 's';
			}else
			if([c isEqualToString:@"ù"] || [c isEqualToString:@"Ù"]){
				cout[count++] = 'u';
				mark = 'f';
			}else
			if([c isEqualToString:@"ụ"] || [c isEqualToString:@"Ụ"]){
				cout[count++] = 'u';
				mark = 'j';
			}else
			if([c isEqualToString:@"ủ"] || [c isEqualToString:@"Ủ"]){
				cout[count++] = 'u';
				mark = 'r';
			}else
			if([c isEqualToString:@"ũ"] || [c isEqualToString:@"Ũ"]){
				cout[count++] = 'u';
				mark = 'x';
			}else
			if([c isEqualToString:@"ư"] || [c isEqualToString:@"Ư"]){
				cout[count++] = 'u';
				cout[count++] = 'w';
				mark = 0;
			}else
			if([c isEqualToString:@"ứ"] || [c isEqualToString:@"Ứ"]){
				cout[count++] = 'u';
				cout[count++] = 'w';
				mark = 's';
			}else
			if([c isEqualToString:@"ừ"] || [c isEqualToString:@"Ừ"]){
				cout[count++] = 'u';
				cout[count++] = 'w';
				mark = 'f';
			}else
			if([c isEqualToString:@"ự"] || [c isEqualToString:@"Ự"]){
				cout[count++] = 'u';
				cout[count++] = 'w';
				mark = 'j';
			}else
			if([c isEqualToString:@"ử"] || [c isEqualToString:@"Ử"]){
				cout[count++] = 'u';
				cout[count++] = 'w';
				mark = 'r';
			}else
			if([c isEqualToString:@"ữ"] || [c isEqualToString:@"Ữ"]){
				cout[count++] = 'u';
				cout[count++] = 'w';
				mark = 'x';
			}else
			if([c isEqualToString:@"ý"] || [c isEqualToString:@"Ý"]){
				cout[count++] = 'y';
				mark = 's';
			}else
			if([c isEqualToString:@"ỳ"] || [c isEqualToString:@"Ỳ"]){
				cout[count++] = 'y';
				mark = 'f';
			}else
			if([c isEqualToString:@"ỵ"] || [c isEqualToString:@"Ỵ"]){
				cout[count++] = 'y';
				mark = 'j';
			}else
			if([c isEqualToString:@"ỷ"] || [c isEqualToString:@"Ỷ"]){
				cout[count++] = 'y';
				mark = 'r';
			}else
			if([c isEqualToString:@"ỹ"] || [c isEqualToString:@"Ỹ"]){
				cout[count++] = 'y';
				mark = 'x';
			}else{
				unichar s = [c characterAtIndex:0];
				if(s == '0'){
					cout[count++] = 'k';
					cout[count++] = 'h';
					cout[count++] = 'o';
					cout[count++] = 'o';
					cout[count++] = 'n';
					cout[count++] = 'g';
					cout[count++] = ' ';
					mark = 0;
				}else if(s == '1'){
					cout[count++] = 'm';
					cout[count++] = 'o';
					cout[count++] = 'o';
					cout[count++] = 't';
					cout[count++] = 'j';
					cout[count++] = ' ';
					mark = 0;
				}else if(s == '2'){
					cout[count++] = 'h';
					cout[count++] = 'a';
					cout[count++] = 'i';
					cout[count++] = ' ';
					mark = 0;
				}else if(s == '3'){
					cout[count++] = 'b';
					cout[count++] = 'a';
					cout[count++] = ' ';
					mark = 0;
				}else if(s == '4'){
					cout[count++] = 'b';
					cout[count++] = 'o';
					cout[count++] = 'o';
					cout[count++] = 'n';
					cout[count++] = 's';
					cout[count++] = ' ';
					mark = 0;
				}else if(s == '5'){
					cout[count++] = 'n';
					cout[count++] = 'a';
					cout[count++] = 'w';
					cout[count++] = 'm';
					cout[count++] = ' ';
					mark = 0;
				}else if(s == '6'){
					cout[count++] = 's';
					cout[count++] = 'a';
					cout[count++] = 'u';
					cout[count++] = 's';
					cout[count++] = ' ';
					mark = 0;
				}else if(s == '7'){
					cout[count++] = 'b';
					cout[count++] = 'a';
					cout[count++] = 'a';
					cout[count++] = 'y';
					cout[count++] = 'r';
					cout[count++] = ' ';
					mark = 0;
				}else if(s == '8'){
					cout[count++] = 't';
					cout[count++] = 'a';
					cout[count++] = 'm';
					cout[count++] = 's';
					cout[count++] = ' ';
					mark = 0;
				}else if(s == '9'){
					cout[count++] = 'c';
					cout[count++] = 'h';
					cout[count++] = 'i';
					cout[count++] = 'n';
					cout[count++] = 's';
					cout[count++] = ' ';
					mark = 0;
				}else 
				if(s == '.' || s==';' || s==',' || s=='\r' || s=='\n' || s==')' || s=='\"' ||s=='\'' || s==' ' || s=='?' || s=='!' || s=='~' || s == '-'){
					if(mark != 0){
						cout[count++] = mark;
						mark = 0;
					}
					cout[count++] = ' ';//s;
					//cout[count++] = s;
					//cout[count++] = ' ';
				}else
					if (s > 127) {
						cout[count++] = (s >> 8) & (1 << 8) - 1;
						cout[count++] = s & (1 << 8) - 1; 
					} else {
						cout[count++] = s;
					}
			} 
	}
	
	if(mark != 0){
		cout[count++] = mark;
		mark = 0;
		cout[count] = 0;
	}
	
	return cout;
}

/*
 char* convertToTelexInput(NSString* str){
 unichar c;
 char mark =0;
 size_t size = ([str length]*3+3)*sizeof(char);
 char* cout = (char*)malloc(size);
 memset(cout, 0, size);
 size_t count =0;
 for (NSUInteger i=0; i<[str length]; i++) {
 c = [str characterAtIndex:i];
 if(c == 'á' || c == 'Á'){
 cout[count++] = 'a';
 mark = 's';
 
 }//else
 if(c == 'à' || c == 'À'){
 cout[count++] = 'a';
 mark = 'f';
 }//else
 if(c == 'ạ' || c == 'Ạ'){
 cout[count++] = 'a';
 mark = 'j';
 }//else
 if(c == 'ả' || c == 'Ả'){
 cout[count++] = 'a';
 mark = 'r';
 }//else
 if(c == 'ã' || c == 'Ã'){
 cout[count++] = 'a';
 mark = 'x';
 }//else
 if(c == 'ă' || c == 'Ă'){
 cout[count++] = 'a';
 cout[count++] = 'w';
 mark = 0;
 }//else
 if(c == 'ắ' || c == 'Ắ'){
 cout[count++] = 'a';
 cout[count++] = 'w';
 mark = 's';
 }else
 if(c == 'ằ' || c == 'Ằ'){
 cout[count++] = 'a';
 cout[count++] = 'w';
 mark = 'f';
 }else
 if(c == 'ặ' || c == 'Ặ'){
 cout[count++] = 'a';
 cout[count++] = 'w';
 mark = 'j';
 }else
 if(c == 'ẳ' || c == 'Ẳ'){
 cout[count++] = 'a';
 cout[count++] = 'w';
 mark = 'r';
 }else
 if(c == 'ẵ' || c == 'Ẵ'){
 cout[count++] = 'a';
 cout[count++] = 'w';
 mark = 'x';
 }else
 if(c == 'â' || c == 'Â'){
 cout[count++] = 'a';
 cout[count++] = 'a';
 mark = 0;
 }else
 if(c == 'ấ' || c == 'Ấ'){
 cout[count++] = 'a';
 cout[count++] = 'a';
 mark = 's';
 }else
 if(c == 'ầ' || c == 'Ầ'){
 cout[count++] = 'a';
 cout[count++] = 'a';
 mark = 'f';
 }else
 if(c == 'ậ' || c == 'Ậ'){
 cout[count++] = 'a';
 cout[count++] = 'a';
 mark = 'j';
 }else
 if(c == 'ẩ' || c == 'Ẩ'){
 cout[count++] = 'a';
 cout[count++] = 'a';
 mark = 'r';
 }else
 if(c == 'ẫ' || c == 'Ẫ'){
 cout[count++] = 'a';
 cout[count++] = 'a';
 mark = 'x';
 }else
 if(c == 'đ' || c == 'Đ'){
 cout[count++] = 'd';
 cout[count++] = 'd';
 mark = 0;
 }else
 if(c == 'ê' || c == 'Ê'){
 cout[count++] = 'e';
 cout[count++] = 'e';
 mark = 0;
 }else
 if(c == 'ế' || c == 'Ế'){
 cout[count++] = 'e';
 cout[count++] = 'e';
 mark = 's';
 }else
 if(c == 'ề' || c == 'Ề'){
 cout[count++] = 'e';
 cout[count++] = 'e';
 mark = 'f';
 }else
 if(c == 'ệ' || c == 'Ệ'){
 cout[count++] = 'e';
 cout[count++] = 'e';
 mark = 'j';
 }else
 if(c == 'ể' || c == 'Ể'){
 cout[count++] = 'e';
 cout[count++] = 'e';
 mark = 'r';
 }else
 if(c == 'ễ' || c == 'Ễ'){
 cout[count++] = 'e';
 cout[count++] = 'e';
 mark = 'x';
 }else
 if(c == 'é' || c == 'É'){
 cout[count++] = 'e';
 mark = 's';
 }else
 if(c == 'è' || c == 'È'){
 cout[count++] = 'e';
 mark = 'f';
 }else
 if(c == 'ẹ' || c == 'Ẹ'){
 cout[count++] = 'e';
 mark = 'j';
 }else
 if(c == 'ẻ' || c == 'Ẻ'){
 cout[count++] = 'e';
 mark = 'r';
 }else
 if(c == 'ẽ' || c == 'Ẽ'){
 cout[count++] = 'e';
 mark = 'x';
 }else
 if(c == 'í' || c == 'Í'){
 cout[count++] = 'i';
 mark = 's';
 }else
 if(c == 'ì' || c == 'Ì'){
 cout[count++] = 'i';
 mark = 'f';
 }else
 if(c == 'ị' || c == 'Ị'){
 cout[count++] = 'i';
 mark = 'j';
 }else
 if(c == 'ỉ' || c == 'Ỉ'){
 cout[count++] = 'i';
 mark = 'r';
 }else
 if(c == 'ĩ' || c == 'Ĩ'){
 cout[count++] = 'i';
 mark = 'x';
 }else
 if(c == 'ó' || c == 'Ó'){
 cout[count++] = 'o';
 mark = 's';
 }else
 if(c == 'ò' || c == 'Ò'){
 cout[count++] = 'o';
 mark = 'f';
 }else
 if(c == 'ọ' || c == 'Ọ'){
 cout[count++] = 'o';
 mark = 'j';
 }else
 if(c == 'ỏ' || c == 'Ỏ'){
 cout[count++] = 'o';
 mark = 'r';
 }else
 if(c == 'õ' || c == 'Õ'){
 cout[count++] = 'o';
 mark = 'x';
 }else
 if(c == 'ô' || c == 'Ô'){
 cout[count++] = 'o';
 cout[count++] = 'o';
 mark = 0;
 }else
 if(c == 'ố' || c == 'Ố'){
 cout[count++] = 'o';
 cout[count++] = 'o';
 mark = 's';
 }else
 if(c == 'ồ' || c == 'Ồ'){
 cout[count++] = 'o';
 cout[count++] = 'o';
 mark = 'f';
 }else
 if(c == 'ộ' || c == 'Ộ'){
 cout[count++] = 'o';
 cout[count++] = 'o';
 mark = 'j';
 }else
 if(c == 'ổ' || c == 'Ổ'){
 cout[count++] = 'o';
 cout[count++] = 'o';
 mark = 'r';
 }else
 if(c == 'ỗ' || c == 'Ỗ'){
 cout[count++] = 'o';
 cout[count++] = 'o';
 mark = 'x';
 }else
 if(c == 'ơ' || c == 'Ơ'){
 cout[count++] = 'o';
 cout[count++] = 'w';
 mark = 0;
 }else
 if(c == 'ớ' || c == 'Ớ'){
 cout[count++] = 'o';
 cout[count++] = 'w';
 mark = 's';
 }else
 if(c == 'ờ' || c == 'Ờ'){
 cout[count++] = 'o';
 cout[count++] = 'w';
 mark = 'f';
 }else
 if(c == 'ợ' || c == 'Ợ'){
 cout[count++] = 'o';
 cout[count++] = 'w';
 mark = 'j';
 }else
 if(c == 'ở' || c == 'Ở'){
 cout[count++] = 'o';
 cout[count++] = 'w';
 mark = 'r';
 }else
 if(c == 'ỡ' || c == 'Ỡ'){
 cout[count++] = 'o';
 cout[count++] = 'w';
 mark = 'x';
 }else
 if(c == 'ú' || c == 'Ú'){
 cout[count++] = 'u';
 mark = 's';
 }else
 if(c == 'ù' || c == 'Ù'){
 cout[count++] = 'u';
 mark = 'f';
 }else
 if(c == 'ụ' || c == 'Ụ'){
 cout[count++] = 'u';
 mark = 'j';
 }else
 if(c == 'ủ' || c == 'Ủ'){
 cout[count++] = 'u';
 mark = 'r';
 }else
 if(c == 'ũ' || c == 'Ũ'){
 cout[count++] = 'u';
 mark = 'x';
 }else
 if(c == 'ư' || c == 'Ư'){
 cout[count++] = 'u';
 cout[count++] = 'w';
 mark = 0;
 }else
 if(c == 'ứ' || c == 'Ứ'){
 cout[count++] = 'u';
 cout[count++] = 'w';
 mark = 's';
 }else
 if(c == 'ừ' || c == 'Ừ'){
 cout[count++] = 'u';
 cout[count++] = 'w';
 mark = 'f';
 }else
 if(c == 'ự' || c == 'Ự'){
 cout[count++] = 'u';
 cout[count++] = 'w';
 mark = 'j';
 }else
 if(c == 'ử' || c == 'Ử'){
 cout[count++] = 'u';
 cout[count++] = 'w';
 mark = 'r';
 }else
 if(c == 'ữ' || c == 'Ữ'){
 cout[count++] = 'u';
 cout[count++] = 'w';
 mark = 'x';
 }else
 if(c == 'ý' || c == 'Ý'){
 cout[count++] = 'y';
 mark = 's';
 }else
 if(c == 'ỳ' || c == 'Ỳ'){
 cout[count++] = 'y';
 mark = 'f';
 }else
 if(c == 'ỵ' || c == 'Ỵ'){
 cout[count++] = 'y';
 mark = 'j';
 }else
 if(c == 'ỷ' || c == 'Ỷ'){
 cout[count++] = 'y';
 mark = 'r';
 }else
 if(c == 'ỹ' || c == 'Ỹ'){
 cout[count++] = 'y';
 mark = 'x';
 }else if(c == '.' || c==';' || c==',' || c=='\r' || c=='\n' || c==')' || c=='\"' ||c=='\'' || c==' ' || c=='?' || c=='!' || c=='~'){
 if(mark != 0){
 cout[count++] = mark;
 mark = 0;
 }
 cout[count++] = c;
 }else
 if (c > 127) {
 cout[count++] = (c >> 8) & (1 << 8) - 1;
 cout[count++] = c & (1 << 8) - 1; 
 } else {
 cout[count++] = c;
 }
 }
 
 if(mark != 0){
 cout[count++] = mark;
 mark = 0;
 cout[count] = 0;
 }
 
 return cout;
 }
*/
bool vntts(NSString* strInput, char* wavFilePath, int nVolume, NSString* sPath)
{
    if(g_lpszVNTTSDataPath == NULL){
        
        g_lpszVNTTSDataPath = strdup([sPath UTF8String]);
        //g_lpszVNTTSDataPath = strdup([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Sample11025Hz/"] UTF8String]);
	}
    /*
	if(g_lpszVNTTSDataPath == NULL){
		//g_lpszVNTTSDataPath = strdup([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Sample11025Hz/"] UTF8String]);
	}
	*/
    
	char* text = convertToTelexInput(strInput);
	
	//int pos = 0;
	char* lpszText = (char*)calloc(strlen(text) + 1,1);
	char* lpszTmp = lpszText;
	__int16* worddata = NULL;
	__int16* ttsdata = NULL;
	__int32 totalsamps = 0;
	__int32 samples = 0;
	__int32 more = 0;
	char stop = '\0';
	char lpszWord[32];
	char lpszD1[32];
	char lpszD2[32];
	strcpy(lpszText,text);
	
	if(text){
		free(text);
		text = NULL;
	}
	
	int delta = 1;//range: 1-700(ms)
	
	do
	{
		memset(lpszWord,0,32);
		memset(lpszD1,0,32);
		memset(lpszD2,0,32);
		lpszTmp = GetWord(lpszWord,lpszTmp);
		stop = '\0';
		if ((lpszWord[strlen(lpszWord) - 1] == ',')||(lpszWord[strlen(lpszWord) - 1] == '.'))
		{
			stop = lpszWord[strlen(lpszWord) - 1];
			lpszWord[strlen(lpszWord) - 1] = '\0';
		}
		if (strlen(lpszWord) > 0)
		{
			if (GetDiphones(lpszWord,lpszD1,lpszD2))
			{
				worddata = DiphConcat(lpszD1,lpszD2,samples);
				if (worddata)
				{
					if (samples < 1500*4)///6144*4
						more = (1500*4)+40*delta; //1 tu luon dai ~700ms ///6144*4
					else
						more = samples+40*delta;
					
					totalsamps += more;
					//totalsamps+=40*m_Slider.GetPos();
					if (!ttsdata)
						ttsdata = (__int16*)calloc(totalsamps,sizeof(__int16));
					else
						ttsdata = (__int16*)realloc(ttsdata,totalsamps*sizeof(__int16));
					
					memset(ttsdata+totalsamps-more,0,more*sizeof(__int16));				
					memcpy(ttsdata+totalsamps-more,worddata,samples*sizeof(__int16));
					
					free(worddata);
					worddata = NULL;
				}else
				{
					//MessageBox(lpszWord,"Error");					
				};
			}else
			{
				//MessageBox("Invalid word!","Error");
				break;
			}
		}
		//MessageBox(lpszD1,"diph 1");
		//MessageBox(lpszD2,"diph 2");
		switch (stop)
		{
			case ',':
				more = 4096*4;///6096*4
				break;
			case '.':
				more = 6144*4;///6144*4
				break;
		}
		if (stop != '\0')
		{
			totalsamps += more;
			if (!ttsdata)
				ttsdata = (__int16*)calloc(totalsamps,sizeof(__int16));
			else
				ttsdata = (__int16*)realloc(ttsdata,totalsamps*sizeof(__int16));
			memset(ttsdata+totalsamps-more,0,more*sizeof(__int16));				
		}
	}while (lpszTmp != NULL);
	
	if (worddata)
	{
		free(worddata);
		worddata = NULL;
	};
	
	free(lpszText);
	lpszText = NULL;
	//GetDlgItem(IDC_EDIT_TEXT)->SetWindowText("");
	//GetDlgItem(IDC_EDIT_TEXT)->SetFocus();
	
	if (ttsdata)
	{
		SaveWave16Bit44100Hz(wavFilePath,ttsdata,totalsamps, nVolume);
		//PlaySound("c:\\tts.wav",NULL,SND_FILENAME);
		free(ttsdata);
		ttsdata = NULL;
		
		return true;
	}
	
	return false;
}



#ifdef __cplusplus
};
#endif

#endif
