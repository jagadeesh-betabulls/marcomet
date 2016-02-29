package com.marcomet.tools;

/**********************************************************************
Description:	This class is intended to handle all error and message
		logging needs.

History:
	Date		Author			Description
	----		------			-----------
	6/06/2001	Brian Murphy		Created

**********************************************************************/
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class MessageLogger {

	public static boolean toScreen = true;
	public static ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
	public static String errorFileName = bundle.getString("ErrorFileName");
	public static String messageFileName = bundle.getString("MessageFileName");
	
	public static void log(Exception ex, String errorMessage, String filename) throws ServletException {
	
		try {
		
			java.io.PrintWriter fileWriter = new java.io.PrintWriter(new java.io.FileOutputStream(filename, true));
			fileWriter.print(new java.util.Date().toString());
			fileWriter.print(" - ");
			fileWriter.print(ex.getClass().getName());
			fileWriter.print(" : ");
			fileWriter.println(errorMessage);
			ex.printStackTrace(fileWriter);
			fileWriter.close();

		} catch (java.io.IOException exception) {
		}

		if (toScreen == true) 
			throw new ServletException(ex.getClass().getName() + " : " + errorMessage + "\n The exception returned this message: " + ex.getMessage());

	} // log(Exception, String, String)
	public static void log(String errorMessage, String filename) throws ServletException {
		try {

			java.io.PrintWriter fileWriter = new java.io.PrintWriter(new java.io.FileOutputStream(filename, true));
			fileWriter.print(new java.util.Date().toString());
			fileWriter.print("   ");
			fileWriter.println(errorMessage);
			fileWriter.close();

		} catch (java.io.IOException exception) {
		}

		
		if (toScreen == true) 
			throw new ServletException(errorMessage);
	} // log(String, String)
	public static void logError(Exception ex, String errorMessage) throws Exception {
		log(ex, errorMessage, MessageLogger.errorFileName);
	} // logError(Exception, String)
	public static void logError(String errorMessage) throws Exception {
		log(errorMessage, MessageLogger.errorFileName);
	} // logError(String)
	public static void logMessage(String message) throws Exception {
		toScreen = false;
		log(message, MessageLogger.messageFileName);
	} // logMessage
} // MessageLogger
