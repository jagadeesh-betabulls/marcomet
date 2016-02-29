package com.marcomet.tools;

/**********************************************************************
Description:	This Class is used by Marcomet classes as the go between
				from Marcomet classes to Verisigns System.  It formats the 
				parameters into a long query string, and processing the results
				into a Hashtable.  The Hashtable is sent back to the calling class
				for its use.

	
**********************************************************************/

import java.sql.SQLException;
import java.util.Hashtable;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;

import paypal.payflow.PayflowAPI;
import paypal.payflow.PayflowConstants;
import paypal.payflow.SDKProperties;

import com.marcomet.commonprocesses.ProcessCreditTransaction;
import com.marcomet.environment.SiteHostSettings;

public class ProcessACHWithVerisignTool {
		private Hashtable<String, Comparable> returnResults;
		private String orderId="NewOrder";
    	ProcessCreditTransaction pct = new ProcessCreditTransaction();
    	
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
					returnResults.put("authCode","ACH");
					returnResults.put("pnRefId",(String)results.get("PNREF"));
		        	//Update the credit transactions table 
		        	pct.setLastref((String)results.get("PNREF"));
		        	if(!pct.getTxType().equals("A")){
			        	try {
							pct.processInsert();
						} catch (SQLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
		        	}

					break;
				case 12:
					returnResults.put("processed",new Boolean(false));
					returnResults.put("ccErrorMessage","There was an error processing this transaction: the electronic check purchase has been declined by the approval agency.");				
					break;
				case 22:
					returnResults.put("processed",new Boolean(false));
					returnResults.put("ccErrorMessage","There was an error processing this transaction: this is an invalid ABA Routing number, please check the number and try again.");
					break;
				case 23:
					returnResults.put("processed",new Boolean(false));
					returnResults.put("ccErrorMessage","There was an error processing this transaction: this is an invalid account number, please check the number and try again.");
					break;
				case 25:
					returnResults.put("processed",new Boolean(false));
					returnResults.put("ccErrorMessage","There was an error validating this account, please contact customer support.");
					break;			
				default:
					returnResults.put("processed",new Boolean(false));
					returnResults.put("ccErrorMessage","There was an error processing this transaction, please call customer support and give them the following error message: " + (String)results.get("RESULT") + " Msg: " + (String)results.get("RESPMSG"));
			}
		}

		public Hashtable processTransaction(String preNote,String firstName,String aba,String ccn, String acctType, String bankName,String bankCity,String bankState,String amount, String trType, HttpServletRequest request){
	        // Payflow Pro Host Name. This is the host name for the PayPal Payment Gateway.
	        // For testing: 	 pilot-payflowpro.paypal.com
	        // For production:   payflowpro.paypal.com
	        // DO NOT use payflow.verisign.com or test-payflow.verisign.com!

			pct.setContactId(request.getSession().getAttribute("contactId").toString());
			//if a past ref id is passed lookup the card info for that transaction and use it.

			if(request.getParameter("pastACref")!=null && !request.getParameter("pastACref").equals("") && !request.getParameter("pastACref").equals("NEW")){
				pct.setPastref(request.getParameter("pastACref"));
			}else{
				String ccString=((acctType==null)?"Other Account":((acctType.equals("C"))?"Checking Account":((acctType.equals("S"))?"Savings Account":"Other Account")));
				pct.setAcctType(acctType);
				pct.setMaskedNum("***********"+ccn.substring(ccn.length()-4,ccn.length()));
				pct.setBankName(bankName);
				pct.setBankCity(bankCity);
				pct.setBankState(bankState);
				pct.setExpDate("0000");
			}
			
	        SDKProperties.setHostPort(443);
	        SDKProperties.setTimeOut(60);
	        String pId=((request.getSession().getAttribute("lastCCRef")!=null && !request.getSession().getAttribute("lastCCRef").toString().equals(""))?"&ORIGID="+request.getSession().getAttribute("lastCCRef").toString():"");
	        orderId=((request.getAttribute("orderId")!=null && !request.getAttribute("orderId").toString().equals(""))?request.getAttribute("orderId").toString():orderId);
	        if(request.getSession().getAttribute("lastCCRef")!=null){
	        	request.getSession().removeAttribute("lastCCRef");
	        }
	        amount=((preNote.equals("Y"))?"0.00":amount);
	        preNote=((preNote.equals("Y"))?"&PRENOTE=Y":"");
	        trType=((pId.equals(""))?trType:"D");
			pct.setTxType(trType);
			
	        // Logging is by default off. To turn logging on uncomment the following lines:
	        SDKProperties.setLogFileName("payflow_java.log");
	        SDKProperties.setLoggingLevel(PayflowConstants.SEVERITY_DEBUG);
	        SDKProperties.setMaxLogFileSize(1000000);
	        SDKProperties.setHostAddress(((request.getParameter("cch")==null || request.getParameter("cch").equals(""))?"pilot-payflowpro.paypal.com":request.getParameter("cch")));
	        SDKProperties.setURLStreamHandlerClass("sun.net.www.protocol.https.Handler");
	        //SDKProperties.setStackTraceOn(true);

	        // Uncomment the lines below and set the proxy address and port, if a proxy has to be used.
	        //SDKProperties.setProxyAddress("");
	        //SDKProperties.setProxyPort(0);
	        //SDKProperties.setProxyLogin("");
	        //SDKProperties.setProxyPassword("");

	        // Create an instance of PayflowAPI.
	        PayflowAPI pa = new PayflowAPI();
			returnResults = new Hashtable<String, Comparable>();
			returnResults.put("processed",new Boolean(false));         //preload with false should anything fail
			returnResults.put("authCode","Not a real Transaction");
			returnResults.put("pnRefId","Not a Tranaction");	
			returnResults.put("ccErrorMessage","");	

	       // RequestId is a unique string that is required for each & every transaction.
	        // The merchant can use her/his own algorithm to generate this unique request id or
	        // use the SDK provided API to generate this as shown below (PayflowAPI.generateRequestId).
	        String requestId = pa.generateRequestId();
	        String amountStr=((request.getParameter("cch")==null || request.getParameter("cch").equals(""))?"1.01":amount);
	        	//"1.01";
			int commerce = Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getCCommerce());
			if (commerce == 0) {
				returnResults.put("processed", new Boolean(true));
				return returnResults;
			} else if (commerce == 1) {
		        SDKProperties.setHostAddress("pilot-payflowpro.paypal.com");
			} else if (commerce == 2) {
				amountStr= amount;
		        SDKProperties.setHostAddress("payflowpro.paypal.com");
		    }

			
			String requestStr="";
			//if(request.getParameter("pastACref")==null || request.getParameter("pastACref").equals("") || request.getParameter("pastACref").equals("NEW")){
		    requestStr = "DESC=Online Order&FIRSTNAME="+firstName+preNote+"&ABA="+aba+"&TRXTYPE="+trType+"&ACCT="+ccn+"&ACCTTYPE="+acctType+pId+"&TENDER=A&AUTHTYPE=WEB&INVNUM="+((request.getParameter("jobId")==null)?"Order:"+orderId:"Job:"+request.getParameter("jobId"))+"&AMT="+amountStr+"&PARTNER=VeriSign&VENDOR=marcomet&USER=mcwebsys&PWD=!x74%st9";
			//}else{
			//	requestStr="TRXTYPE="+trType+"&TENDER=A&PARTNER=VeriSign&VENDOR=marcomet&USER=mcwebsys&PWD=!x74%st9&ORIGID="+request.getParameter("pastACref")+"&AMT="+amount;
			//}
			
	        
			String rc = pa.submitTransaction(requestStr, requestId);;
			checkResults(rc);
			
	        // Create a new Client Information data object.
	        //ClientInfo clInfo = new ClientInfo();

	        // Set the ClientInfo object of the PayflowAPI.
	        //pa.setClientInfo(clInfo);

	          System.out.println("HOST: "+SDKProperties.getHostAddress()+", ACH Transaction Request :\n-------------------- \n" + requestStr);
	          System.out.println("ACH Transaction Response :\n-------------------- \n" + rc);

	        // Following lines of code are optional.
	        // Begin optional code for displaying SDK errors ...
	        // It is used to read any errors that might have occured in the SDK.
	        // Get the transaction errors.

	        String transErrors = pa.getTransactionContext().toString();
	        if (transErrors != null && transErrors.length() > 0) {
	            System.out.println("ACH Transaction Errors from SDK = \n" + transErrors);
	        }
			return returnResults;

	    }


		public String getOrderId() {
			return orderId;
		}


		public void setOrderId(String orderId) {
			this.orderId = orderId;
		}
	}