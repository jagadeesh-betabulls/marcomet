<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,java.util.*,com.marcomet.environment.*,com.marcomet.jdbc.*,com.marcomet.tools.*" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
String tempString ="";
StringTool str=new StringTool();
DecimalFormat nf = new DecimalFormat("#,###.00");
DecimalFormat decFormatter = new DecimalFormat("#,###.##");

int numLines=0;
String keyStr="";
int x=0;
String selected=((request.getParameter("selectedTab")==null)?"1":request.getParameter("selectedTab"));
String jobId=((request.getParameter("jobId")==null)?"":request.getParameter("jobId"));
String ioNumber=((request.getParameter("ioNumber")==null)?"":request.getParameter("ioNumber"));
String ioNum="";
String hRow="<table id='io' class='sortable' width='100%' cellpadding=2><tr>";
String contPropSQL="Select distinct i.property as 'property_code',cp.title as 'title' from v_contact_properties cp left join io_prop_site_bridge iob on cp.property_code=iob.site_number left join insertions  i on iob.io_property_number=i.property where property_code<>0 and i.id is not null and contact_id="+(String)session.getAttribute("contactId")+" order by property_code";
ResultSet rsContProds = st.executeQuery(contPropSQL);
int cnt=0;
String propFilter="";
String propNum="";
if (!(((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isSiteHost())){
	while(rsContProds.next()){
		propFilter+=((cnt==0)?" AND (i.property='"+rsContProds.getString("property_code")+"' ":" OR i.property='"+rsContProds.getString("property_code")+"' ");
		cnt++;
		propNum=rsContProds.getString("title");
	}
}
propFilter+=((propFilter.equals(""))?"":") ");

String ioSQL="Select distinct concat('IO_',replace(i.io_number,'-0-','-NTH-'),'.pdf') as 'H:File', if(ios.id is null,'',ios.io_status) as 'H:Status', DATEDIFF(i.material_close_date,curdate()) as 'Days^Until-Due',i.id 'H:id', i.io_number 'P:L:IO-Number',media_vehicle 'L:Media-Vehicle',media_type 'L:Media-Type',Region 'L:Region',unit_size 'L:Unit~Size',DATE_FORMAT(i.creative_start_date,'%m/%d/%Y') 'L:-Creative^Start-Date-',DATE_FORMAT(i.material_close_date,'%m/%d/%Y') 'L:-Material^Close-Date-',i.ad_number 'L:Insertion^Ad-Number',if(jsa.value is null,'N/A',jsa.value) as 'K:Production^Ad-Number' from insertions i left join io_status ios on ios.io_number=i.io_number  left join job_specs js on js.value=i.io_number AND js.cat_spec_id='11035' left join job_specs jsa on js.job_id=jsa.job_id and jsa.cat_spec_id='11036'  where  ( (jsa.value is not null and jsa.value<>'' and  i.material_close_date>=now() )  or (  ( (jsa.value is null or jsa.value='') and  DATEDIFF(now(),i.material_close_date)<16 ) )) and i.Plan_Status<>'cancelled' "+propFilter+" order by i.creative_start_date ";

%>
<html><head><title>Insertions</title>
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
</head><body><jsp:include page="/sitehosts/marketdolce/includes/MediaTabBar.jsp" >
	<jsp:param name="selectedTab" value="<%=selected%>" />
</jsp:include><div class='subtitle'>Insertion Orders <%=((cnt==1)?"For Property: "+propNum:"")%></div>
<table width=100% class='gridTable' cellpadding=1><tr><%

ResultSet rs = st.executeQuery(ioSQL);
ResultSetMetaData rsmd = rs.getMetaData();
int numberOfColumns = rsmd.getColumnCount();
tempString = null;
Vector headers  = new Vector(15);
for (int i=1 ;i <= numberOfColumns; i++){
	tempString = new String ((String) rsmd.getColumnLabel(i));
	headers.add(tempString);
	if (tempString.indexOf("H:")==-1){
tempString=str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring( str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempString,"H:", ""),"F:", ""),"B:", ""),"K:", ""),"C:", ""),"L:", ""),"^"," <br /> "),"-", "&nbsp;"),"P:", "");
		%><td  class='tableheader' ><%=tempString%></td><%
	}
}
%><td  class='tableheader' >ACTION</td>
</tr>
<%
x=0;
numLines=0;
boolean showAction=false;
while (rs.next()){
	boolean ioRow=((rs.getString("H:id").equals(ioNumber))?true:false);
	String rowClass=(( (rs.getString("K:Production^Ad-Number")!=null && !(rs.getString("K:Production^Ad-Number").equals("N/A"))) || (rs.getString("H:Status")!=null && !(rs.getString("H:Status").equals(""))) )?"lineitems":((rs.getInt("Days^Until-Due")<16)?"lineitemsselected":((rs.getInt("Days^Until-Due")<31)?"lineitemsselected1":"lineitems")));
	
	%><tr><%
	for (int i=0;i < numberOfColumns; i++){
		String columnName = (String) headers.get(i);
		String columnValue=((columnName.indexOf("F:")>-1)?nf.format(rs.getDouble(columnName)):((rs.getString(columnName)==null)?"":rs.getString(columnName) ));
		if(columnName.indexOf("H:")>-1){
			keyStr=columnValue;
		}else if(columnName.indexOf("K:")>-1){
			showAction=((columnValue.equals("N/A"))?true:false);
			%><td class='<%=rowClass%>' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=((showAction)?columnValue:"<a href=\"javascript:pop('/popups/JobDetailsPage.jsp?jobId="+columnValue.substring(columnValue.indexOf("_")+1, columnValue.length())+"','700','300')\" class='minderLink'>"+columnValue+"</a></td>")%><%	
		}else if(columnName.indexOf("P:")>-1){
			ioNum=columnValue;
			%><td class='<%=rowClass%>' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><a href='<%=(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+rs.getString("H:File")%>' class='minderLink' target='_blank'><%=columnValue%></a></td><%		
		}else{
			%><td class='<%=rowClass%>' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%></td><%
		}
	}
	
	if(showAction && rs.getString("H:Status").equals("")){
	%><td class='<%=rowClass%>'><div align='center'><a href='javascript:pop("/popups/QuickChangeIOStatus.jsp?ioNumber=<%=ioNum%>",200,100)' class='utilityNav'>&nbsp;Change&nbsp;IO&nbsp;Status&nbsp;</a>&nbsp;|&nbsp;<a href='/contents/items.jsp?prodLineId=74000700&ShowInactive=&ShowRelease=STD08&ioNumber=<%=rs.getString("P:L:IO-Number")%>&specId1=6052&6052=NEW&specId=6045&6045=&prePopTable=v_insertions&prePopId=<%=keyStr%>' class='utilityNav'>&nbsp;Create&nbsp;New&nbsp;Ad&nbsp;</a>&nbsp;|&nbsp;<a href='/contents/AdChoice.jsp?ioNumber=<%=ioNum%>&ioId=<%=keyStr%>&prePopTable=v_insertions&prePopId=<%=keyStr%>' class='utilityNav'>&nbsp;Pickup&nbsp;Prior&nbsp;Ad&nbsp;</a></div></td><%
	}else{
	%><td class='<%=rowClass%>'><div align='center'><%=((rs.getString("H:Status").equals(""))?"Ad Ordered":rs.getString("H:Status") + "&nbsp;|&nbsp;<a href='javascript:pop(\"/popups/QuickChangeIOStatus.jsp?ioNumber="+rs.getString("P:L:IO-Number")+"\",200,100)' class='utilityNav'>&nbsp;Change&nbsp;IO&nbsp;Status&nbsp;</a>")%></div></td><%
	}
	x++;
	%></tr>
	<%
} 
	%></table><%
if (x==0){
	%><div class='subtitle'>No Insertions for this property.</div><%
}  
	st.close();
	conn.close();
%></body></html>