<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<% UserProfile up = (UserProfile)session.getAttribute("userProfile");
   SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
int i = 0;
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();

String queryValueAddProg = "select vac.id as promo_credit_id,vap.id as vap_id, vap.value_add_prog_code, c.default_site_number as 'Site Number', vap.value_add_program_name as'Promotion',vap.prog_end_date as 'End Date', if(vac.amount_qualified is null,0,vac.amount_qualified) as 'Credit Given', (if(sum(arc.check_amount) is null,0,sum(arc.check_amount)) + if(sum(jc.price) is null,0,(-1*sum(jc.price)))) as 'Credit Used', vac.amount_qualified - (if(sum(arc.check_amount) is null,0,sum(arc.check_amount)) + if(sum(jc.price) is null,0,(-1*sum(jc.price))))  as 'Credit_Balance',DATE_FORMAT(vap.prog_end_date,'%m/%d/%y') as 'Expires'  from contacts c inner join value_add_credits vac on vac.property_code=c.default_site_number inner join value_add_programs vap on vap.value_add_prog_code = vac.value_add_prog_code and vap.prog_end_date >= Now() left join ar_collections arc on vac.id = arc.value_add_credit_id left join jobchanges jc on vac.id = jc.value_add_credit_id where c.id = " + up.getContactId() + " group by vap.value_add_prog_code";

ResultSet rsValueAddProg = st.executeQuery(queryValueAddProg);
while(rsValueAddProg.next()){
	if (rsValueAddProg.getString("Credit_Balance")!=null && (rsValueAddProg.getDouble("Credit_Balance")>0)){
		if (i++==0){%><script language="javascript" src="/javascripts/mainlib.js"></script><link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css"><table border="0" cellpadding="3" cellspacing="0" width=100%><tr>
		<td align="center" valign='middle' class="leftNavBarItemOver2" height='20' colspan="3"><span class='leftNavBarItemHover2'>Promotional Credits: </span></td></tr><tr>
        <td class="tableheader" align='center' width='60'>Program (click for details)</td>
        <td class="tableheader" align='center'>Credit<br>Balance</td>
        <td class="tableheader" align='center'>Expires</td><%}
        %><tr>
        <td class="lineitemsright" ><a href='javascript:pop("/popups/ClientPromoCreditDetailPage1.jsp?id=<%=rsValueAddProg.getString("vap_id")%>",400,300);' ><%=rsValueAddProg.getString("Promotion")%></a></td>
        <td class="lineitemsright" ><%= formater.getCurrency(rsValueAddProg.getString("Credit_Balance")) %></td>
        <td class="lineitemsright" ><%= rsValueAddProg.getString("Expires") %></td></tr><%
	}
}
st.close();
conn.close();
if(i>0){%></table><%}%>