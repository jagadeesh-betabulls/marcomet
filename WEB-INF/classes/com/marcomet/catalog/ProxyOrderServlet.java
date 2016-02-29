package com.marcomet.catalog;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.StringTokenizer;

import com.marcomet.tools.ReturnPageContentServlet;

public class ProxyOrderServlet extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		int proxyContactId = 0;
		int proxyCompanyId = 0;

		StringTokenizer st = new StringTokenizer(request.getParameter("proxyContact"), ":");
		if (st.hasMoreTokens()) {
			proxyContactId = Integer.parseInt(st.nextToken());
			proxyCompanyId = Integer.parseInt(st.nextToken());
		}
			
		ProxyOrderObject poo = new ProxyOrderObject(true, proxyContactId, proxyCompanyId);
		request.getSession().setAttribute("ProxyOrderObject", poo);

		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this, request, response);

	}
}
