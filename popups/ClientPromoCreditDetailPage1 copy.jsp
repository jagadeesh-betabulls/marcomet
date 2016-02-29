<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<% UserProfile up = (UserProfile)session.getAttribute("userProfile");
   SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
int i = 0;
Double totCredit=0.0;
String expireDate="";
String vapId=((request.getParameter("id")==null)?"0":request.getParameter("id"));
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
%><html>
	<head>
  	<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  	<link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
  		<script language="javascript" src="/javascripts/mainlib.js"></script>
  		<title>Promotional Credit Details</title>
	</head>
	<body><%
String queryValueAddProg = "select vac.id as promo_credit_id, c.default_site_number as 'Site Number',if(ari.invoice_number is null,'N/A',ari.invoice_number) as 'Invoice Number', vap.value_add_program_description as 'description',vap.value_add_program_name as'Promotion',vap.prog_end_date as 'End Date', if(vac.amount_qualified is null,0,vac.amount_qualified) as 'Credit Given', (if((arc.check_amount) is null,0,(arc.check_amount))+ if((jc.price) is null,0,(-1 * jc.price))) as 'Credit Used',if(arid.jobid is null,if(jc.id is null,'N/A',jc.jobid),arid.jobid) as 'Job Number',DATE_FORMAT(vap.prog_end_date,'%m/%d/%y') as 'Expires'  from contacts c inner join value_add_credits vac on vac.property_code=c.default_site_number inner join value_add_programs vap on vap.value_add_prog_code = vac.value_add_prog_code and vap.prog_end_date >= Now() left join ar_collections arc on vac.id = arc.value_add_credit_id left join ar_collection_details arcd on arcd.ar_collectionid=arc.id left join ar_invoices ari on ari.id=arcd.ar_invoiceid left join ar_invoice_details arid on arid.ar_invoiceid=ari.id left join jobchanges jc on vac.id = jc.value_add_credit_id  where vap.id="+vapId+" AND c.id = " + up.getContactId() ;

ResultSet rsValueAddProg = st.executeQuery(queryValueAddProg);
while(rsValueAddProg.next()){
		if (i++==0){
			totCredit+=rsValueAddProg.getDouble("Credit Given");
			expireDate=rsValueAddProg.getString("Expires");
			%><link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css"><table border="0" cellpadding="3" cellspacing="0" align="center"><tr><td class=subtitle colspan=5><div class="subtitle" align='center'>Promotional Credits: <%=rsValueAddProg.getString("Promotion")%></div><%=((rsValueAddProg.getString("description")==null)?"":"<span class='bodyBlack'>"+rsValueAddProg.getString("description")+"</span>")%></td></tr><tr><td class="tableheader" align='center' colspan=2>Site Number: <%=rsValueAddProg.getString("Site Number")%></td><td class="tableheader" align='right' colspan=2>Total Credit: <%= formater.getCurrency(rsValueAddProg.getString("Credit Given"))%></td></tr>
        <tr>
        <td class="tableheader" align='center' >Invoice Number</td>
        <td class="tableheader" align='center' >Job Number</td>
        <td class="tableheader" align='center' >Credit Applied</td></tr><%}
        %><tr>
        <td class="lineitemsright" ><%= rsValueAddProg.getString("Invoice Number")%></td>
        <td class="lineitemsright" ><%= rsValueAddProg.getString("Job Number")%></td>
        <td class="lineitemsright" ><%= formater.getCurrency(rsValueAddProg.getString("Credit Used")) %></td><%
        totCredit=totCredit-rsValueAddProg.getDouble("Credit Used");
        %>
        </tr>
        <%
}
st.close();
conn.close();
if(i>0){%><tr><td class="lineitemsright" colspan=2 bgcolor=#c1c4c3>Balance Unused: </td><td class="lineitemsright"><strong><%= formater.getCurrency(totCredit) %></strong></td></tr>
        <tr><td class="lineitemsright" colspan=2 bgcolor=#c1c4c3>Expires: </td><td class="lineitemsright"><strong><%= expireDate %></strong></td></tr><tr><td colspan=5 align="center"><br><br><a href='javascript:window.close();' class='graybutton'>CLOSE</a></td></tr></table><%}%></body></html>