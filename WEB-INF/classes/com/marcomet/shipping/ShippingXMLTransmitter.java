package com.marcomet.shipping;

import java.io.*;
import java.util.*;
import java.net.*;
//import Sun's JSSE package to deal with SSL. To use JSSE, you need JDK 1.2.1
//import javax.net.ssl.*;
import java.security.*;
import com.sun.net.ssl.*;
import java.net.Authenticator;
import java.net.PasswordAuthentication;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * The XmlTransmitter will transmit an HTTP/HTTPS post with the StringBuffer provided as 
 * the data of the post message.  The XmlTransmitter must be constructed with a URL or
 * IP address and a protocol to use for transmitting the message.
 */
public class ShippingXMLTransmitter {

  private String hostname;
  private String protocol;
  private StringBuffer XmlIn;
  private StringBuffer XmlOut;
  private static java.lang.String encodedPass;

  /**
   * Constructs a new XmlTransmitter for purposes of HTTPS posts not inhibited by
   * a Proxy Server or FireWall.
   * @param hostname java.lang.String
   * @param protocol java.lang.String
   * @param keyring java.lang.String
   *
   */
  public ShippingXMLTransmitter(String hostname, String protocol) {
    this.hostname = hostname.trim();
    this.protocol = protocol.trim();
  }

  /**
   * This method is used to send the XmlTransmitter information to a designated service.
   * @param service java.lang.String
   * @param prefix java.lang.String
   * @throws java.lang.Exception
   */
  public void contactService(String service) throws Exception {
    HttpURLConnection connection;
    URL url;
    try {
      // Create new URL and connect
      if (protocol.equalsIgnoreCase("https")) {
        //use Sun's JSSE to deal with SSL
        java.security.Security.addProvider(new com.sun.net.ssl.internal.ssl.Provider());
        System.getProperties().put("java.protocol.handler.pkgs", "com.sun.net.ssl.internal.www.protocol");
      }
      url = new URL(protocol + "://" + hostname + "/" + service);
      connection = (HttpURLConnection) url.openConnection();

      // Setup HTTP POST parameters
      connection.setDoOutput(true);
      connection.setDoInput(true);
      connection.setUseCaches(false);
      if (ShippingXMLTransmitter.encodedPass != null) {
        connection.setRequestProperty("Proxy-Authorization", ShippingXMLTransmitter.encodedPass);
      }

      // Get POST data from input StringBuffer containing an XML document
      String queryString = XmlIn.toString();

      // POST data
      OutputStream out = connection.getOutputStream();
      out.write(queryString.getBytes());
      out.close();

      // Get data from URL connection and return the XML document as a StringBuffer
      String data = "";
      try {
        data = readURLConnection(connection);
      }
      catch (Exception e) {
        System.out.println("Eror in reading URL Connection" + e.getMessage());
        throw e;
      }
      XmlOut = new StringBuffer(data);
    }
    catch (Exception ex) {
      Logger.getLogger(ShippingXMLTransmitter.class.getName()).log(Level.SEVERE, null, ex);
    }
  }

  /**
   * This method returns the xml response, from the XmlTransmitter's URL, to the caller of method.
   * @return java.lang.StringBuffer
   */
  public StringBuffer getXml() {
    return XmlOut;
  }

  /**
   * Setter for purposes of giving the XmlTransmitter the request data.
   * @param input java.lang.StringBuffer
   */
  public void setXml(StringBuffer input) {
    this.XmlIn = input;
  }

  /**
   * Reads an input file to a String
   * @return java.lang.String
   * @param file java.lang.String
   */
  public static StringBuffer readInputFile(String file) throws Exception {
    StringBuffer xml = new StringBuffer();
    InputStreamReader in = new InputStreamReader(new FileInputStream(file));
    LineNumberReader lineReader = new LineNumberReader(in);
    String line_xml = null;
    while ((line_xml = lineReader.readLine()) != null) {
      xml.append(line_xml);
    }
    lineReader.close();
    return xml;
  }

  /**
   * This method read all of the data from a URL conection to a String
   */
  private static String readURLConnection(URLConnection uc) throws Exception {
    StringBuffer buffer = new StringBuffer();
    BufferedReader reader = null;
    try {
      reader = new BufferedReader(new InputStreamReader(uc.getInputStream()));
      int letter = 0;
      while ((letter = reader.read()) != -1) {
        buffer.append((char) letter);
      }
    }
    catch (Exception e) {
      System.out.println("Cannot read from URL" + e.toString());
      throw e;
    }
    finally {
      try {
        reader.close();
      }
      catch (IOException io) {
        System.out.println("Error closing URLReader!");
        throw io;
      }
    }
    return buffer.toString();
  }

  /**
   * writes the String to the file
   * @param str java.lang.String
   * @param file java.lang.String
   */
  public static void writeOutputFile(StringBuffer str, String file) throws Exception {
    FileOutputStream fout = new FileOutputStream(file);
    fout.write(str.toString().getBytes());
    fout.close();
  }
}
