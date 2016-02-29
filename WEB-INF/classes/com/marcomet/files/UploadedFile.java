package com.marcomet.files;

import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.marcomet.files.multipart.MultipartParser;
import com.marcomet.files.multipart.Part;
import com.marcomet.files.multipart.FilePart;
import com.marcomet.files.multipart.ParamPart;


// A class to hold information about an uploaded file.
//
class UploadedFile {

  private String dir;
  private String filename;
  private String type;
  private long size = 0;

  UploadedFile(String dir, String filename, String type, long size) {
	this.dir = dir;
	this.filename = filename;
	this.type = type;
	this.size = size;
  }    
  public String getContentType() {
	return type;
  }  
  public File getFile() {
	if (dir == null || filename == null) {
	  return null;
	}
	else {
	  return new File(dir + File.separator + filename);
	}
  }  
  public long getFileSize() {
	  return size;
  }    
  public String getFilesystemName() {
	return filename;
  }  
}
