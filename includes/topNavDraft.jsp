<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.users.security.*,java.util.*,java.util.Vector, com.marcomet.catalog.*;" %>
<%
ShoppingCart cart = (ShoppingCart)session.getAttribute("shoppingCart");
Vector projects = null;
boolean isOrder = false;
if (cart != null) {
	projects = cart.getProjects();
	if(projects.size() > 0){
		isOrder = true;
	}
} else {
	projects = new Vector();
}

boolean editor= (((RoleResolver)session.getAttribute("roles")).roleCheck("editor") && request.getParameter("isTopNav")!=null);
boolean isTopNav=((request.getParameter("isTopNav") ==null || request.getParameter("isTopNav").equals("true") || request.getParameter("isTopNav").equals(""))?true:false);
String ShowRelease=((request.getParameter("ShowRelease")==null || request.getParameter("ShowRelease").equals("")) ? "":" AND nav_menus.release='"+request.getParameter("ShowRelease")+"' ");

String ShowInactive=((request.getParameter("ShowInactive")==null || request.getParameter("ShowInactive").equals(""))?" AND status_id=2 ":""); 

String pageName=((request.getParameter("pageName")==null || request.getParameter("pageName").equals(""))?" AND page_name='home' ":" AND page_name= '"+request.getParameter("pageName")+"' "); 

String sitehostId=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId();
if(isTopNav){
%><link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script src="/javascripts/prototype.js" type="text/javascript"></script>
<script src="/javascripts/scriptaculous.js" type="text/javascript"></script>
<script src="/javascripts/menu.js" type="text/javascript"></script>
<script>
	function logMeOut(){;
		<%if (isOrder){
	%>if(confirm("You have jobs pending which have not yet been processed for order, if you log out now these will be lost. Do you want to continue? (Click Cancel to return to your shopping cart to process these jobs.)")){
			window.location.replace("/logmeout.jsp");
		}else{
			window.location.replace("/frames/InnerFrameset.jsp?contents=/catalog/summary/OrderSummary.jsp");
		}<%
}else{
	%>window.location.replace("/logmeout.jsp");<%
}%>
	}
</script><%
}%>
		<div id="menu">
			<ul class="level1" id="root"><%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery("SELECT  n.*,sh.sh_target as sh_target FROM nav_menus n,site_hosts sh where n.sitehost_id=sh.id and sh.id="+sitehostId+pageName+ShowInactive+ShowRelease+" ORDER BY sequence");

int x=1;
int y=1;
int level=1;
String lastMenu="";
String lastId="";
String levelStr="level1";
Hashtable hMenus=new Hashtable<String,Integer>();
Hashtable hDD1=new Hashtable<String,String>();
Hashtable hDD2=new Hashtable<String,String>();
String target="";
String shTarget="";
while(rs.next()){

	target=((rs.getString("target").equals(""))?((rs.getString("sh_target")==null || rs.getString("sh_target").equals(""))?"mainFr":rs.getString("sh_target")):rs.getString("target"));
	shTarget=((rs.getString("sh_target")==null || rs.getString("sh_target").equals(""))?"mainFr":rs.getString("sh_target"));

	if (rs.getString("menu_parent").equals(rs.getString("id"))){ //if this is a top level Menu
		hMenus.put(rs.getString("id"),1);
		while(level-- >1){
			%></li></ul><%
		}
		y=0;
		level=1;
		%><%=((x++>1)?"</li>":"")%>
		<li><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=50&rows=1&question=Change%20Link%20Text&primaryKeyValue=<%=rs.getString("id")%>&columnName=link_text&tableName=nav_menus&valueType=string",500,150)'>&raquo;&nbsp;</a><%}%><a href="<%=((rs.getString("status_id").equals("1"))?rs.getString("link")+"&Draft=true":rs.getString("link"))%>" target='<%=target%>' id='l<%=rs.getString("id")%>' ><%=((rs.getString("status_id").equals("1"))?rs.getString("link_text")+"&nbsp;[DRAFT]&nbsp;":rs.getString("link_text"))%></a><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=100&rows=1&question=Change%20Link%20URL&primaryKeyValue=<%=rs.getString("id")%>&columnName=link&tableName=nav_menus&valueType=string",700,150)'>&nbsp;&laquo;&nbsp;</a><%}%><%
		
	}else{ //if this is a secondary level menu

		if (rs.getString("menu_parent").equals(lastId)){ //if this is the first of the next level submenu	
			if (level==1){
				hDD1.put(lastId,rs.getString("menu_parent"));
			}else{
				hDD2.put(lastId,rs.getString("menu_parent"));
			}
			level++; //increase the level
%>
			<ul class='level<%=level%>'><%
			if (hMenus.get(rs.getString("menu_parent"))==null){ //if this menu hasn't been logged yet, add it to the mix.
				hMenus.put(rs.getString("id"),level);
			}
			
		}else if (hMenus.get(rs.getString("menu_parent"))!=null && !(rs.getString("menu_parent").equals(lastMenu)) ){ //if this level menu has been used before
			//level--;
			while(level-- >(Integer.parseInt(hMenus.get(rs.getString("menu_parent")).toString()))+1){
				%>
				</li>
			</ul><%
			}
				level=Integer.parseInt(hMenus.get(rs.getString("menu_parent")).toString()) + 1;
				
		}else{ //if this is a new submenu item
			%>
				</li><%
		}
		%>
				<li><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=50&rows=1&question=Change%20Link%20Text&primaryKeyValue=<%=rs.getString("id")%>&columnName=link_text&tableName=nav_menus&valueType=string",500,150)'>&raquo;&nbsp;</a><%}%><a href="<%=((rs.getString("status_id").equals("1"))?rs.getString("link")+"&Draft=true":rs.getString("link"))%>" target='<%=target%>' id='l<%=rs.getString("id")%>' ><%=((rs.getString("status_id").equals("1"))?rs.getString("link_text")+"&nbsp;[DRAFT]&nbsp;":rs.getString("link_text"))%></a><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=50&rows=1&question=Change%20Link%20URL&primaryKeyValue=<%=rs.getString("id")%>&columnName=link&tableName=nav_menus&valueType=string",500,150)'>&nbsp;&laquo;&nbsp;</a><%}%><%
	}
	lastMenu=rs.getString("menu_parent");
	lastId=rs.getString("id");
}	
		%></li><%
		//If 
		if (isOrder) {
			%><li><a href="/catalog/summary/OrderSummary.jsp" target="<%=shTarget%>" ><img src="/images/cart.gif">&nbsp;PROCESS&nbsp;JOBS</a></li><%
			} 
			%>
		</ul><span id='menuText'>&nbsp; &nbsp; &nbsp; &nbsp; WELCOME <%= session.getAttribute("UserFullName") %>!</span></div>
<script><%
Vector v1 = new Vector(hDD1.keySet());
Iterator e = v1.iterator();
Vector v2 = new Vector(hDD2.keySet());
Iterator f = v2.iterator();
int c=0;
while (e.hasNext()) {
	%>
	var x=document.getElementById("l<%=(String)e.next()%>").className='parent';<%	
}
while (f.hasNext()) {
	%>
	var x=document.getElementById("l<%=(String)f.next()%>").className='parent';<%	
}
%>
</script><%
rs.close();
st.close();
conn.close();%>