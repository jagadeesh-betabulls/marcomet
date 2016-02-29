<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<%
	if(request.getParameter("jobId") != null){
			com.marcomet.workflow.actions.CalculateJobCosts cjc = new com.marcomet.workflow.actions.CalculateJobCosts();
			cjc.calculate(request.getParameter("jobId"));
	}else{		
%>		
<script language="javascript">alert("you're a boob, you forgot the job number");</script>
<%	
	}
%>	
<body bgcolor="#FFFFFF" text="#000000">

</body>
</html>
