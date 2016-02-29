

<%=((session.getAttribute("roles")==null)?"<script language = javascript> window.location.replace(\"/admin/no_user.jsp\") </script>":((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).roleCheckRedirect("registered user","/admin/no_user.jsp") )%>
<script language = javascript> window.location.replace("<%=((request.getParameter("reDirect")==null)?"/admin/page_not_found.jsp":request.getParameter("reDirect"))%>") </script>
<body>

</body>
</html>
