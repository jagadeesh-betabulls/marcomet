package com.marcomet.files;

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.marcomet.files.multipart.MultipartParser;
import com.marcomet.files.multipart.Part;
import com.marcomet.files.multipart.FilePart;
import com.marcomet.files.multipart.ParamPart;


public class MultipartRequest {

  private static final int DEFAULT_MAX_POST_SIZE = 1024 * 1024;  // 1 Meg

  private Hashtable parameters = new Hashtable();  // name - Vector of values
  private Hashtable files = new Hashtable();       // name - UploadedFile
  private Vector fileNames = new Vector();
  private HttpSession session;
  private HttpServletRequest request = null;
  
  public MultipartRequest(HttpServletRequest request,
						  int maxPostSize, File dir) throws IOException {
	// Sanity check values
	if (request == null)
	  throw new IllegalArgumentException("request cannot be null");
	if (maxPostSize <= 0) {
	  throw new IllegalArgumentException("maxPostSize must be positive");
	}

	this.request = request;
	session = request.getSession();
	
	// Parse the incoming multipart, storing files in the dir provided, 
	// and populate the meta objects which describe what we found
	MultipartParser parser = new MultipartParser(request, maxPostSize);
	Part part;
	int available = 0;
	File file = null;
	FileInputStream fip = null;

	while ((part = parser.readNextPart()) != null) {

	  String name = part.getName();

	  if (part.isParam()) {
		// It's a parameter part, add it to the vector of values
		ParamPart paramPart = (ParamPart) part;
		String value = paramPart.getStringValue();
		Vector existingValues = (Vector)parameters.get(name);
		if (existingValues == null) {
		  existingValues = new Vector();
		  parameters.put(name, existingValues);
		}
		
		existingValues.addElement(value);

	  } else if (part.isFile()) {
 
		// It's a file part
		FilePart filePart = (FilePart) part;
		//String fileName = filePart.getFileName();
		String fileName = filePart.getFileName();
		
		if (fileName != null) {
			// The part actually contained a file
			// Check saveDirectory is truly a directory
			if (!dir.isDirectory()) {
				dir.mkdir();
			}

			// Check saveDirectory is writable
			if (!dir.canWrite())
	  			throw new IllegalArgumentException("Not writable: " + dir.getAbsolutePath());

			try {
				file = new File(dir, fileName);
				fip = new FileInputStream(file);
				available = fip.available();
			} catch(Exception ex) {}

			long length = filePart.writeTo(dir);
			files.put(name, new UploadedFile(dir.toString(), fileName, filePart.getContentType(), length));
			fileNames.addElement(fileName);
		} else { 
		  // The field did not contain a file
		  files.put(name, new UploadedFile(null, null, null, 0));
		}
	  } // if
	} // while

  }              
  /**
   * Returns the content type of the specified file (as supplied by the 
   * client browser), or null if the file was not included in the upload.
   *
   * @param name the file name.
   * @return the content type of the file.
   */
  public String getContentType(String name) {
	try {
	  UploadedFile file = (UploadedFile)files.get(name);
	  return file.getContentType();  // may be null
	}
	catch (Exception e) {
	  return null;
	}
  }  
  /**
   * Returns a File object for the specified file saved on the server's 
   * filesystem, or null if the file was not included in the upload.
   *
   * @param name the file name.
   * @return a File object for the named file.
   */
  public File getFile(String name) {
	try {
	  UploadedFile file = (UploadedFile)files.get(name);
	  return file.getFile();  // may be null
	}
	catch (Exception e) {
	  return null;
	}
  }  
  public String getFileNameByVectorPosition(int i) {
	return (String)fileNames.elementAt(i);
  }  
  /**
   * Returns the names of all the uploaded files as an Enumeration of 
   * Strings.  It returns an empty Enumeration if there are no uploaded 
   * files.  Each file name is the name specified by the form, not by 
   * the user.
   *
   * @return the names of all the uploaded files as an Enumeration of Strings.
   */
  public Enumeration getFileNames() {
	return files.keys();
  }  
  /**
   * Returns the filesystem name of the specified file, or null if the 
   * file was not included in the upload.  A filesystem name is the name 
   * specified by the user.  It is also the name under which the file is 
   * actually saved.
   *
   * @param name the file name.
   * @return the filesystem name of the file.
   */
  public String getFilesystemName(String name) {
	try {
	  UploadedFile file = (UploadedFile)files.get(name);
	  return file.getFilesystemName();  // may be null
	}
	catch (Exception e) {
	  return null;
	}
  }  
  public int getNumberOfFiles() {
  	return fileNames.size();
  }  
  /**
   * Returns the value of the named parameter as a String, or null if 
   * the parameter was not sent or was sent without a value.  The value 
   * is guaranteed to be in its normal, decoded form.  If the parameter 
   * has multiple values, only the last one is returned (for backward 
   * compatibility).  For parameters with multiple values, it's possible
   * the last "value" may be null.
   *
   * @param name the parameter name.
   * @return the parameter value.
   */
  public String getParameter(String name) {
	try {
	  Vector values = (Vector)parameters.get(name);
	  if (values == null || values.size() == 0) {
		return null;
	  }
	  String value = (String)values.elementAt(values.size() - 1);
	  return value;
	}
	catch (Exception e) {
	  return null;
	}
  }  
  /**
   * Returns the names of all the parameters as an Enumeration of 
   * Strings.  It returns an empty Enumeration if there are no parameters.
   *
   * @return the names of all the parameters as an Enumeration of Strings.
   */
  public Enumeration getParameterNames() {
	return parameters.keys();
  }  
  /**
   * Returns the values of the named parameter as a String array, or null if 
   * the parameter was not sent.  The array has one entry for each parameter 
   * field sent.  If any field was sent without a value that entry is stored 
   * in the array as a null.  The values are guaranteed to be in their 
   * normal, decoded form.  A single value is returned as a one-element array.
   *
   * @param name the parameter name.
   * @return the parameter values.
   */
  public String[] getParameterValues(String name) {
	try {
	  Vector values = (Vector)parameters.get(name);
	  if (values == null || values.size() == 0) {
		return null;
	  }
	  String[] valuesArray = new String[values.size()];
	  values.copyInto(valuesArray);
	  return valuesArray;
	}
	catch (Exception e) {
	  return null;
	}
  }  
  /*********************************
  This method is used for gaining access to the session object.
  Purpose is that the session has values/object needed by workflow actions/emails
  thomas dietrich
  *********************************/
  public HttpSession getSession(){
	return session;
  }  
  /**
   * Returns a File object for the specified file saved on the server's 
   * filesystem, or null if the file was not included in the upload.
   *
   * @param name the file name.
   * @return a File object for the named file.
   */
  public UploadedFile getUploadedFile(String name) {
	try {
	  UploadedFile file = (UploadedFile)files.get(name);
	  return file;  // may be null
	}
	catch (Exception e) {
	  return null;
	}
  }    
  public void putFile(String name, UploadedFile uf) {
	files.put(name, uf);
  }  
  // Alternative method for when you already have an object to place in the parameters hash
  public void setParameter(String key, Object o) {
	parameters.put(key, o);
  }  
  /*************************************************************************
  This method is used to populate parameters in the request object
  Brian Murphy
  *************************************************************************/
  
  public void setParameter(String name, String value) {
	Vector v = new Vector();
	v.addElement(value);
	parameters.put(name, v);
  }  
}
