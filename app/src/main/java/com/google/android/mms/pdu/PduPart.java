package com.google.android.mms.pdu;
import android.net.Uri;
public class PduPart {
 private int charset; private byte[] contentId, contentType, contentLocation, data; private Uri dataUri;
 public int getCharset(){return charset;} public void setCharset(int v){charset=v;}
 public byte[] getContentId(){return contentId;} public void setContentId(byte[] v){contentId=v;}
 public byte[] getContentType(){return contentType;} public void setContentType(byte[] v){contentType=v;}
 public byte[] getContentLocation(){return contentLocation;} public void setContentLocation(byte[] v){contentLocation=v;}
 public byte[] getData(){return data;} public void setData(byte[] v){data=v;}
 public Uri getDataUri(){return dataUri;} public void setDataUri(Uri v){dataUri=v;}
}
