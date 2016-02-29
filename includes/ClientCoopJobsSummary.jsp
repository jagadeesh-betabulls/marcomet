<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<% 
int i=0;
UserProfile up = (UserProfile)session.getAttribute("userProfile");
SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
String arQuery = "Select j.id,pr.prod_code,pr.prod_name,pr.trigger_amount,pr.on_order_amount,DATE_FORMAT(pr.end_date,'%m-%d-%Y') 'end_date',DATE_FORMAT(pr.ship_date,'%m-%d-%Y') 'ship_date',if(pr.end_date is not null,to_days(pr.end_date) ,0) 'closedays',to_days(CurDate()) curdays,if(pr.ship_date is not null,to_days(pr.ship_date),0) 'shipdays' from contacts c, jobs j, v_promo_prods pr where pr.prod_code=j.product_code and pr.trigger_amount>0 and if(c.default_site_number>0, j.site_number=c.default_site_number,j.jbuyer_company_id=c.companyid) and j.order_date>=start_date and j.order_date<=end_date  and c.id="+up.getContactId()+" order by end_date";
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet arRS = st.executeQuery(arQuery);
String headerStr="<table width='100%'><tr><td colspan=6><div class=subtitle align=center>Coop Orders</div></td></tr><tr><td class=tableheader>Job #</td><td class=tableheader>Product</td><td class=tableheader>Orders Needed</td><td class=tableheader>Current Orders</td><td class=tableheader>Close Date</td><td class=tableheader>Status</td></tr>";
String lineStr="";
String statusStr="";
while (arRS.next()) { 
statusStr=((arRS.getInt("trigger_amount") <= arRS.getInt("on_order_amount"))?"Yes":"No");
statusStr=((arRS.getInt("shipdays") <= arRS.getInt("curdays") && statusStr.equals("Yes"))?"Product Shipping":"");
statusStr=((arRS.getInt("closedays") <= arRS.getInt("curdays") && statusStr.equals("Yes"))?"Closed: Min Orders Reached":"");
statusStr=((arRS.getInt("closedays") <= arRS.getInt("curdays") && statusStr.equals("No"))?"Closed: Min Orders Not Reached":"");
lineStr+="<tr class='leftNavBarItem2' onMouseOver=\"this.className='leftNavBarItemOver2';cmslnk"+i+".className='leftNavBarItemHover2'\" onMouseOut=\"this.className='leftNavBarItem2';cmslnk"+i+".className='leftNavBarItem2'\" onClick=\"pop('/popups/promoDetails.jsp?id="+arRS.getString("sale_id")+"',600,400)\"><td class=lineitems>"+arRS.getString("id")+"</td><td class=lineitems>"+arRS.getString("product")+"</td><td class=lineitems>"+arRS.getString("trigger_amount")+"</td><td class=lineitems>"+arRS.getString("on_order_amount")+"</td><td class=lineitems>"+arRS.getString("end_date")+"</td><td class=lineitems>"+statusStr+"</td></tr>";
i++;
}
if (i>0){
	%><script language="JavaScript" src="/javascripts/mainlib.js"></script><%=headerStr%><%=lineStr%></table><%
}
arRS.close();
st.close();
conn.close();
%>

