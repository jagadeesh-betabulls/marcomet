package com.marcomet.files.multipart;

import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.ServletInputStream;

/**
 * A <code>FilePart</code> is an upload part which represents a 
 * <code>INPUT TYPE="file"</code> form parameter.
 * 
 * @author Geoff Soutter
 * @version 1.2, 2001/01/22, getFilePath() addition thanks to Stefan Eissing
 * @version 1.1, 2000/11/26, writeTo() bug fix thanks to Mike Shivas
 * @version 1.0, 2000/10/27, initial revision
 */
public class FilePart extends Part {
  
  /** "file system" name of the file  */
  private String fileName;     
  
  /** path of the file as sent in the request, if given */
  private String filePath;

  /** content type of the file */
  private String contentType;   
  
  /** input stream containing file data */
  private PartInputStream partInput;  
	
  /**
   * Construct a file part; this is called by the parser.
   * 
   * @param name the name of the parameter.
   * @param in the servlet input stream to read the file from.
   * @param boundary the MIME boundary that delimits the end of file.
   * @param contentType the content type of the file provided in the 
   * MIME header.
   * @param fileName the file system name of the file provided in the 
   * MIME header.
   * @param filePath the file system path of the file provided in the
   * MIME header (as specified in disposition info).
   * 
   * @exception IOException	if an input or output exception has occurred.
   */
  FilePart(String name, ServletInputStream in, String boundary,
		   String contentType, String fileName, String filePath)
												   throws IOException {
	super(name);
	this.fileName = fileName;
	this.filePath = filePath;
	this.contentType = contentType;
	partInput = new PartInputStream(in, boundary);
  }  
  /** 
   * Returns the content type of the file data contained within.
   * 
   * @return content type of the file data.
   */
  public String getContentType() {
	return contentType;
  }  
  /**
   * Returns the name that the file was stored with on the remote system, 
   * or <code>null</code> if the user didn't enter a file to be uploaded. 
   * Note: this is not the same as the name of the form parameter used to 
   * transmit the file; that is available from the <code>getName</code>
   * method.
   * 
   * @return name of file uploaded or <code>null</code>.
   * 
   * @see Part#getName()
   */
  public String getFileName() {
	return fileName;
  }  
  /**
   * Returns the full path and name of the file on the remote system,
   * or <code>null</code> if the user didn't enter a file to be uploaded.
   * If path information was not supplied by the remote system, this method
   * will return the same as <code>getFileName()</code>.
   *
   * @return path of file uploaded or <code>null</code>.
   *
   * @see Part#getName()
   */
  public String getFilePath() {
	return filePath;
  }  
  /**
   * Returns an input stream which contains the contents of the
   * file supplied. If the user didn't enter a file to upload
   * there will be <code>0</code> bytes in the input stream.
   * It's important to read the contents of the InputStream 
   * immediately and in full before proceeding to process the 
   * next part.  The contents will otherwise be lost on moving
   * to the next part.
   * 
   * @return an input stream containing contents of file.
   */
  public InputStream getInputStream() {
	return partInput;
  }  
  /**
   * Returns <code>true</code> to indicate this part is a file.
   * 
   * @return true.
   */
  public boolean isFile() {
	return true;
  }  
  /**
   * Internal method to write this file part; doesn't check to see
   * if it has contents first.
   *
   * @return number of bytes written.
   * @exception IOException	if an input or output exception has occurred.
   */
  long write(OutputStream out) throws IOException {
	// decode macbinary if this was sent
	if (contentType.equals("application/x-macbinary")) {
	  out = new MacBinaryDecoderOutputStream(out);
	}
	long size=0;
	int read;
	byte[] buf = new byte[8 * 1024];
	while((read = partInput.read(buf)) != -1) {
	  out.write(buf, 0, read);
	  size += read;
	}
	return size;
  }  
  /**
   * Write this file part to a file or directory. If the user 
   * supplied a file, we write it to that file, and if they supplied
   * a directory, we write it to that directory with the filename
   * that accompanied it. If this part doesn't contain a file this
   * method does nothing.
   *
   * @return number of bytes written
   * @exception IOException	if an input or output exception has occurred.
   */
  public long writeTo(File fileOrDirectory) throws IOException {
	long written = 0;
	OutputStream fileOut = null;
	
	try {
	
	  // Only do something if this part contains a file	  
	  if (fileName != null) {
		// Check if user supplied directory
		File file;
		if (fileOrDirectory.isDirectory()) {
		  // Write it to that dir the user supplied, 
		  // with the filename it arrived with
		  file = new File(fileOrDirectory, fileName);
		} else {
		  // Write it to the file the user supplied,
		  // ignoring the filename it arrived with
		  file = fileOrDirectory;		  
		}

		fileOut = new BufferedOutputStream(new FileOutputStream(file));
		written = write(fileOut);
	  }
	  
	} catch(Exception ex) {
		throw new IOException("There was a writeTo(File) error: " + ex.getMessage()); 
	}
	
	finally {
	  if (fileOut != null) fileOut.close();
	}
	return written;
  }  
  /**
   * Write this file part to a file or directory. If the user 
   * supplied a file, we write it to that file, and if they supplied
   * a directory, we write it to that directory with the filename
   * that accompanied it. If this part doesn't contain a file this
   * method does nothing.
   *
   * @return number of bytes written
   * @exception IOException	if an input or output exception has occurred.
   */
  public long writeTo(File fileOrDirectory, File tempDirectory) throws IOException {
	long written = 0;
	OutputStream fileOut = null;
	File tempFile = null;
	
	try {

	  // Only do something if this part contains a file	  
	  if (fileName != null) {
		// Check if user supplied directory
		File file;
		if (fileOrDirectory.isDirectory()) {
		  // Write it to that dir the user supplied, 
		  // with the filename it arrived with
		  file = new File(fileOrDirectory, fileName);
		  tempFile = new File(tempDirectory, fileName);
		} else {
		  // Write it to the file the user supplied,
		  // ignoring the filename it arrived with
		  file = fileOrDirectory;
		  tempFile = tempDirectory;
		}

		int available = 0;
		try {
			FileInputStream fip = new FileInputStream(file);
			available = fip.available();
		} catch(Exception ex) {}
		
		if (available != 0) {
			throw new IOException("exists");
		} else {
			fileOut = new BufferedOutputStream(new FileOutputStream(file));
			written = write(fileOut);
		}
	  }

	} catch(Exception ex) {
		if (ex.getMessage().equals("exists")) {
			throw new IOException("exists");
		} else {
			throw new IOException("The following error occurred in writeTo(File, File): " + ex.getMessage());
		}
	}
	
	finally {
	  if (fileOut != null) fileOut.close();
	}
	return written;
  }  
  /**
   * Write this file part to a file or directory. If the user 
   * supplied a file, we write it to that file, and if they supplied
   * a directory, we write it to that directory with the filename
   * that accompanied it. If this part doesn't contain a file this
   * method does nothing.
   *
   * @return number of bytes written
   * @exception IOException	if an input or output exception has occurred.
   */
  public long writeTo(File fileOrDirectory, Hashtable parameters) throws IOException {
	long written = 0;
	Vector vec = null;
	OutputStream fileOut = null;
	
	try {

	  // Only do something if this part contains a file	  
	  if (fileName != null) {	  
		// Check if user supplied directory
		File file;
		
		if (fileOrDirectory.isDirectory()) {
		  // Write it to that dir the user supplied, 
		  // with the filename it arrived with
		  file = new File(fileOrDirectory, fileName);
		} else {
		  // Write it to the file the user supplied,
		  // ignoring the filename it arrived with
		  file = fileOrDirectory;		  
		}
		
		String write = "";
		String name = "";
		vec = (Vector)parameters.get("write");
		write = (String)vec.elementAt(0);

		if(file.exists()) {

			if (write.equals("")) {
				throw new IOException();
			//} else if (write.equals("rename")) {
			//	vec = (Vector)parameters.get("newFileName");
			//	name = (String)vec.elementAt(0);

			//	fileOut = new BufferedOutputStream(new FileOutputStream(file));
			//	written = write(fileOut);
			} else if (write.equals("replace")) {
				fileOut = new BufferedOutputStream(new FileOutputStream(file));
				written = write(fileOut);
			}
			
		} else {
			fileOut = new BufferedOutputStream(new FileOutputStream(file));
			written = write(fileOut);
		}
	  }

	} catch(Exception ex) {
		throw new IOException("exists"); 
	}
	
	finally {
	  if (fileOut != null) fileOut.close();
	}
	return written;
  }  
  /**
   * Write this file part to the given output stream. If this part doesn't 
   * contain a file this method does nothing.
   *
   * @return number of bytes written.
   * @exception IOException	if an input or output exception has occurred.
   */
  public long writeTo(OutputStream out) throws IOException {
	long size=0;
	// Only do something if this part contains a file
	if (fileName != null) {
	  // Write it out
	  size = write( out );
	}
	return size;
  }  
}
