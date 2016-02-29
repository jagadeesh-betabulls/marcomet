package com.marcomet.files;

import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class DownloadFile extends HttpServlet {

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		try {

			String content_type;
			//String filename = request.getParameter ("fileName");
			String filename = "/home/httpd/html/transfers/README.TXT";
			File file;

			if (filename == null) return;

			file = new File (filename);

			content_type = "application/octect-stream";

			response.setContentType (content_type);
			response.setHeader ("Content-Disposition", "attachment; filename=\"" + file.getName () + "\"");

			ServletOutputStream out = response.getOutputStream ();
			RandomAccessFile raf = new RandomAccessFile (filename, "r");

			byte b[] = new byte[4096];
			int len;
			while ((len = raf.read(b)) > -1)
				out.write (b, 0, len);

			out.close ();
			raf.close ();

		}

		catch (Exception ex) {
			throw new ServletException ("Error in DownloadFile: " + ex.getMessage());
		}

	}
}
