package com.marcomet.tools;

import java.util.Hashtable;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;

import com.marcomet.environment.SiteHostSettings;

import paypal.payflow.*;

public class NVPSale {
	private Hashtable<String, Comparable> returnResults;
	public void checkResults(String returnCode) {
		
		//Process results from Verisign
		StringTokenizer st1 = new StringTokenizer(returnCode,"&");
		Hashtable<String, String> results = new Hashtable<String, String>();
		
		//load up hashtable for ease and searching
		while (st1.hasMoreTokens()){
			StringTokenizer st2 = new StringTokenizer(st1.nextToken(),"=");
			results.put(st2.nextToken(),st2.nextToken()); 
		}
		
		
		switch(Integer.parseInt((String)results.get("RESULT"))){
			case 0:
				returnResults.put("processed",new Boolean(true));
				returnResults.put("authCode",(String)results.get("AUTHCODE"));
				returnResults.put("pnRefId",(String)results.get("PNREF"));
				break;
			case 12:
				returnResults.put("processed",new Boolean(false));
				returnResults.put("ccErrorMessage","Declined Credit Card Purchase, by Approval Agency");				
				break;
			case 23:
				returnResults.put("processed",new Boolean(false));
				returnResults.put("ccErrorMessage","Invalid Account Number");
				break;
			case 24:
				returnResults.put("processed",new Boolean(false));
				returnResults.put("ccErrorMessage","Invalid Expiration Date");
				break;
			case 25:
				returnResults.put("processed",new Boolean(false));
				returnResults.put("ccErrorMessage","Error with account, please check your Credit Card Number");
				break;			
			default:
				returnResults.put("processed",new Boolean(false));
				returnResults.put("ccErrorMessage","No recog code: " + (String)results.get("RESULT") + " Msg: " + (String)results.get("RESPMSG"));
		}
	}

	
	public Hashtable processTransaction(String ccn, String cced, String amount, HttpServletRequest request){
        // Payflow Pro Host Name. This is the host name for the PayPal Payment Gateway.
        // For testing: 	 pilot-payflowpro.verisign.com
        // For production:   payflowpro.verisign.com
        // DO NOT use payflow.verisign.com or test-payflow.verisign.com!

        SDKProperties.setHostPort(443);
        SDKProperties.setTimeOut(20);


        // Logging is by default off. To turn logging on uncomment the following lines:
        SDKProperties.setLogFileName("payflow_java.log");
        SDKProperties.setLoggingLevel(PayflowConstants.SEVERITY_DEBUG);
        SDKProperties.setMaxLogFileSize(1000000);
        //SDKProperties.setURLStreamHandlerClass("");
        //SDKProperties.setStackTraceOn(true);

        // Uncomment the lines below and set the proxy address and port, if a proxy has to be used.
        //SDKProperties.setProxyAddress("");
        //SDKProperties.setProxyPort(0);
        //SDKProperties.setProxyLogin("");
        //SDKProperties.setProxyPassword("");

        // Create an instantce of PayflowAPI.
        PayflowAPI pa = new PayflowAPI();
		returnResults = new Hashtable<String, Comparable>();
		returnResults.put("processed",new Boolean(false));         //preload with false should anything fail
		returnResults.put("authCode","Not a real Transaction");
		returnResults.put("pnRefId","Not a real Tranaction");	
		returnResults.put("ccErrorMessage","");	
        //Sample Request.
        // Please replace <user>, <vendor>, <password> & <partner> with your merchant information.
       // RequestId is a unique string that is required for each & every transaction.
        // The merchant can use her/his own algorithm to generate this unique request id or
        // use the SDK provided API to generate this as shown below (PayflowAPI.generateRequestId).
        String requestId = pa.generateRequestId();
        String amountStr="1.01";
		int commerce = Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getCCommerce());
		if (commerce == 0) {
			returnResults.put("processed", new Boolean(true));
			return returnResults;
		} else if (commerce == 1) {
	        SDKProperties.setHostAddress("pilot-payflowpro.verisign.com");
		} else if (commerce == 2) {
			amountStr= amount;
	        SDKProperties.setHostAddress("payflowpro.verisign.com");
	    }
        String requestStr = "TRXTYPE=S&ACCT="+ccn+"&EXPDATE="+cced+"&TENDER=C&INVNUM="+request.getParameter("jobId")+"&AMT="+amountStr+"&PARTNER=VeriSign&VENDOR=marcomet&USER=marcomet&PWD=ekccomet";
		String rc = pa.submitTransaction(requestStr, requestId);;
		checkResults(rc);
		
        // Create a new Client Information data object.
        //ClientInfo clInfo = new ClientInfo();

        // Set the ClientInfo object of the PayflowAPI.
        //pa.setClientInfo(clInfo);

 //       System.out.println("Transaction Request :\n-------------------- \n" + requestStr);
  //      System.out.println("Transaction Response :\n-------------------- \n" + rc);

        // Following lines of code are optional.
        // Begin optional code for displaying SDK errors ...
        // It is used to read any errors that might have occured in the SDK.
        // Get the transaction errors.

        String transErrors = pa.getTransactionContext().toString();
        if (transErrors != null && transErrors.length() > 0) {
            System.out.println("Transaction Errors from SDK = \n" + transErrors);
        }
		return returnResults;

    }
}