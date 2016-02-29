package com.marcomet.mail;

/**********************************************************************
Description:	this class handles deliveriing emails via the command line.
				the intentions is run this class via cron job so that the
				submission of forms take place a little quicker.
**********************************************************************/

import com.marcomet.jdbc.*;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.sql.*;

public class CronStart{

public CronStart(){
}
public static void main(String[] args) {
	//CronMailer clm = new CronMailer();
	try{	
		String theURL = "http://marcometws5.virtual.vps-host.net/cronstart.html";
		String aLine = "";
		 
		URL u = new URL(theURL);
		BufferedReader theHTML = new BufferedReader(new InputStreamReader(u.openStream()));
		 
		while (aLine != null) {
		                //Read HTML output from URL
		                System.out.println(aLine);
		                aLine = theHTML.readLine();
		}
	}catch(Exception e){
		System.err.println(e);
		e.printStackTrace();
	}finally{
	System.exit(0);	
	}
}
}
