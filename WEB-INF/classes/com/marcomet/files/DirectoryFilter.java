package com.marcomet.files;

import java.io.*;

public class DirectoryFilter implements FilenameFilter {

	 public boolean accept (File dir, String name) {
			  File file = new File(dir + name);
			  if (file.isDirectory()) {
				   return false;
			  }
			  else {
				   return true;
			  }
	 } 
}
