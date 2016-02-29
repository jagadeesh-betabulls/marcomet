<html>
<head>
</head>
</html><%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<% UserProfile up = (UserProfile)session.getAttribute("userProfile");
   SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
   String shTarget="mainFr";
int i = 0;
int pastdue = 0;
double balanceDue=0.00;
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();

String arBalanceQuery = "select sum(a.invoice_balance)  as balance_due from (select distinct ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance, (TO_DAYS(NOW()) - TO_DAYS(ari.creation_date)) as age from contacts c, jobs j left join ar_invoice_details arid on j.id=arid.jobid  left join ar_invoices ari on arid.ar_invoiceid=ari.id left join ar_collection_details arcd on arcd.ar_invoiceid=ari.id  where ((j.site_number=c.default_site_number and c.default_site_number<>'0' and trim(leading '0' from c.default_site_number)<>'' and c.default_site_number is not null) or (( (c.default_site_number='0' or trim(leading '0' from c.default_site_number)='' or c.default_site_number is null) or (j.site_number='0' or trim(leading '0' from j.site_number)='' or j.site_number is null) ) and j.jbuyer_contact_id=c.id)) and c.id='"+up.getContactId()+"'  and ari.exclude_from_statements<>1 group by ari.invoice_number having (invoice_balance) >0.009 or (invoice_balance) < -0.009 order by ari.creation_date) a ";
   
ResultSet arBalanceRS = st.executeQuery(arBalanceQuery);

if (arBalanceRS.next()) { 
     balanceDue=((arBalanceRS.getString("balance_due")==null)?0:arBalanceRS.getDouble("balance_due"));
}

if (balanceDue > .001){
	
String arQuery = "select distinct ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance, (TO_DAYS(NOW()) - TO_DAYS(ari.creation_date)) as age from contacts c, jobs j left join ar_invoice_details arid on j.id=arid.jobid  left join ar_invoices ari on arid.ar_invoiceid=ari.id left join ar_collection_details arcd on arcd.ar_invoiceid=ari.id  where ((j.site_number=c.default_site_number and c.default_site_number<>'0' and trim(leading '0' from c.default_site_number)<>'' and c.default_site_number is not null) or (((c.default_site_number='0' or trim(leading '0' from c.default_site_number)='' or c.default_site_number is null) or (j.site_number='0' or trim(leading '0' from j.site_number)='' or j.site_number is null)) and j.jbuyer_contact_id=c.id)) and c.id='"+up.getContactId()+"'  and ari.exclude_from_statements<>1 group by ari.invoice_number having (invoice_balance) >0.009 or (invoice_balance) < -0.009 order by ari.creation_date";
	   
	ResultSet arRS = st.executeQuery(arQuery);
	%><script language="JavaScript" src="/javascripts/mainlib.js"></script>
	<table width="100%"><%
	while (arRS.next()) { 
	     if (arRS.getInt("age") > 30 && pastdue == 0) { 
	        %><tr> 
	          <td class="menuLINK" align='center'> 
	           Account Overdue!<br>Please Pay or Call<br><a class="footerentry" href="javascript:pop('<%=(String)session.getAttribute("siteHostRoot")%>/contents/contacts.jsp','650','450')">[Contact Info]</a></td>
		</tr><%
		}
		if ( pastdue == 0) {
		%><tr>
		 	<td align="center" valign='middle' class="leftNavBarItemOver2" height='20'><span class='leftNavBarItemHover2'>Your Invoices Payable: </span></td>
		</tr><%
	 	pastdue = 1;
		}
		if (arRS.getInt("age") >= 0){
	%><tr > 
	<td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';lnk<%=arRS.getString("ari.invoice_number")%>.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';lnk<%=arRS.getString("ari.invoice_number")%>.className='leftNavBarItem2'" height="18">
	<div align "right"><a class="leftNavBarItem2" id='lnk<%=arRS.getString("ari.invoice_number")%>' href="/minders/workflowforms/ReviewInvoice.jsp?invoiceId=<%=arRS.getString("ari.invoice_number")%>" target="<%=shTarget%>" style="font-size:7pt;" ><%=arRS.getString("ari.invoice_number")%>&nbsp;(Age: <%=arRS.getInt("age")%>)&nbsp;&nbsp;&nbsp;<%=arRS.getString("ari.creation_date")%>&nbsp;&nbsp;&nbsp;&nbsp;<%=formatter.getCurrency(arRS.getDouble("invoice_balance"))%></a></div></td>
	<!--          <td align "right"> <a class="minderACTION" href="/minders/workflowforms/ReviewInvoice.jsp?invoiceId=<%=arRS.getString("ari.invoice_number")%>"><%=arRS.getInt("age")%><br>days</a> -->
	        </tr><% 
	i = i + 1;
	 }
	 }
	if (i==0){%><tr><td></td></tr><%}%></table><%

}else{
	if(balanceDue < -.001){
	%><table width="100%"><tr><td class="menuLINK" align='center'>Account Balance<br></td></tr>
<tr><td align="center" valign='middle' class="leftNavBarItemOver2" height='20'><span class='leftNavBarItemHover2'>You have an outstanding credit of: <%=formatter.getCurrency(balanceDue)%></span></td></tr></table><%
	}
}
st.close();
conn.close();
%>

