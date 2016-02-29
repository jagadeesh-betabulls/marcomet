<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
  <head>
    <title>MarketDolce Forms</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
<%
String login=((request.getParameter("ln")==null)?"":request.getParameter("ln"));
%>
  <body>
    <p>Opening MarketDolce Forms...</p><%
      if (request.getParameter("adMgr")!=null){
    %><form action="http://fmforms.marcomet.com/fmi/iwp/cgi" method="get">
      <input type="hidden"   name="dbpath" value="/fmi/iwp/cgi?-db=dolce&-startsession" >
      <input type="hidden"   name="acct"   value="account" >
      <input type="hidden"   name="-authdb">
      <input type="hidden"   name="name" value="Dolce">
      <input type="hidden" name="password" value="Dolce">
    </form>
    <script>
		document.forms[0].submit();
    </script><%
      
      }else	if ( login.equals("en") || login.equals("es") || login.equals("fr") || login.equals("gr") || login.equals("du")){
    %><form action="http://fmforms.marcomet.com/fmi/iwp/cgi" method="get">
      <input type="hidden"   name="dbpath" value="/fmi/iwp/cgi?-db=dolce&-startsession" >
      <input type="hidden"   name="acct"   value="account" >
      <input type="hidden"   name="-authdb">
      <input type="hidden"   name="name" value="<%=login%>">
      <input type="hidden" name="password" value="dolce<%=login%>">
    </form>
    <script>
		document.forms[0].submit();
    </script><%}else{
    %>Error: You are trying to access a page that does not exist.<%
    }%>
	</body>
</html>