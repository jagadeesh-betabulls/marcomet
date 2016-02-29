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
String jobId=((request.getParameter("jobId")==null)?"0":request.getParameter("jobId"));
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();

String queryValueAddProg = "select vac.id as vacId,pr.id as promoId,j.promo_code,vac.id as promo_credit_id, c.default_site_number as 'Site Number',if(ari.invoice_number is null,'N/A',ari.invoice_number) as 'Invoice Number', if(vap.value_add_program_description is null,if(pr.description is null,'',pr.description),vap.value_add_program_description) as 'description',if(vap.value_add_program_name is null,if(pr.title is null,'',pr.title),vap.value_add_program_name) as'Promotion',vap.prog_end_date as 'End Date', if(vac.amount_qualified is null,0,vac.amount_qualified) as 'Credit Given', (if((arc.check_amount) is null,0,(arc.check_amount))+ if((jc.price) is null,0,(-1 * jc.price))) as 'Credit Used',if(arid.jobid is null,if(jc.id is null,'N/A',jc.jobid),arid.jobid) as 'Job Number',DATE_FORMAT(vap.prog_end_date,'%m/%d/%y') as 'Expires'  from jobs j left join promotions pr on j.promo_code=pr.promo_code left join contacts c on c.id=j.jbuyer_contact_id left join value_add_credits vac on vac.property_code=c.default_site_number left join value_add_programs vap on vap.value_add_prog_code = vac.value_add_prog_code and vap.prog_end_date >= Now() left join ar_collections arc on vac.id = arc.value_add_credit_id left join ar_collection_details arcd on arcd.ar_collectionid=arc.id left join ar_invoices ari on ari.id=arcd.ar_invoiceid left join ar_invoice_details arid on arid.ar_invoiceid=ari.id left join jobchanges jc on vac.id = jc.value_add_credit_id where j.id="+jobId ;

ResultSet rsValueAddProg = st.executeQuery(queryValueAddProg);
while(rsValueAddProg.next()){
	if((rsValueAddProg.getString("promo_code")!=null && !rsValueAddProg.getString("promo_code").equals("")) || rsValueAddProg.getString("vacId")!=null || rsValueAddProg.getString("promoId")!=null){
		if (i++==0){
			totCredit+=rsValueAddProg.getDouble("Credit Given");
			expireDate=rsValueAddProg.getString("Expires");
			%><table border="0" cellpadding="3" cellspacing="0" align="center"><%if(!rsValueAddProg.getString("Promotion").equals("")){%><tr><td colspan=3><div class="lineitems">Promo: <%=rsValueAddProg.getString("Promotion")%>; <%=((rsValueAddProg.getString("description")==null)?"":"<span class='bodyBlack'>"+rsValueAddProg.getString("description")+"</span>")%></div></td></tr><%}%>
        <tr>
	        <td class="tableheader" align='center' >Promo Code</td>
	        <td class="tableheader" align='center' >Invoice Number</td>
	        <td class="tableheader" align='center' >Credit Applied</td></tr><%}
        %><tr>
	        <td class="lineitemsright" ><a href="javascript:popw('/popups/PromoCode.jsp?jobId=<%= request.getParameter("jobId")%>', 350, 200)" class="minderACTION">&raquo&nbsp;<%= rsValueAddProg.getString("promo_code")%></a></td>
    	    <td class="lineitemsright" ><%= rsValueAddProg.getString("Invoice Number")%></td>
    	    <td class="lineitemsright" ><%= formater.getCurrency(rsValueAddProg.getString("Credit Used")) %></td><%
        totCredit=totCredit-rsValueAddProg.getDouble("Credit Used");
        %></tr>
        <%
		}
}
st.close();
conn.close();
%><%=((i>0)?"</table>":"<a href='javascript:popw(\"/popups/PromoCode.jsp?jobId="+request.getParameter("jobId")+"\", 350, 200)' class='minderACTION'>&raquo&nbsp;Add Promo Code</a>")%><%
if(i<0){%><tr><td class="lineitemsright" colspan=2 bgcolor=#c1c4c3>Balance Unused: </td><td class="lineitemsright"><strong><%= formater.getCurrency(totCredit) %></strong></td></tr>
        <%if(expireDate !=null){%><tr><td class="lineitemsright" colspan=2 bgcolor=#c1c4c3>Expires: </td><td class="lineitemsright"><strong><%= expireDate %></strong></td></tr><%}}%>