<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
  <head>
    <title>MarketDolce Forms</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>

  <body>
    <p>Opening MarketDolce Forms...</p><%
  if (request.getParameter("adMgr")==null){
  %><form action="http://fmforms.marcomet.com/fmi/iwp/cgi" method="get">
      <input type="hidden"   name="dbpath" value="/fmi/iwp/cgi?-db=dolce&-startsession" >
      <input type="hidden"   name="-authdb">
      <input type="hidden"   name="acct"   value="guest" ><%
  }else{
    %><form action="http://fmforms.marcomet.com/fmi/iwp/cgi" method="get">
      <input type="hidden"   name="dbpath" value="/fmi/iwp/cgi?-db=dolce&-startsession" >
      <input type="hidden"   name="acct"   value="account" >
      <input type="hidden"   name="-authdb">
      <input type="hidden"   name="name" value="Dolce">
      <input type="hidden" name="password" value="Dolce"><%}
      %></form>
    <script>
		document.forms[0].submit();
    </script>
	</body>
</html>