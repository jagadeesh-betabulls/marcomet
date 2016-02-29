/**
 * Verisign Payflow Pro API class
 * Verisign, Inc.
 * http://www.verisign.com
 * 1600 Bridge Parkway, Suite 201
 * Redwood Shores, CA 94065
 * USA
 *
 * (650) 622-2200
 * support@signio.com
 */
package com.Verisign.payment;

// Verisign JNI Client Wrapper - Needs pfprojni.dll or libpfprojni.so in order to load

import java.lang.*;

/**
 * PFProAPI - Verisign Payflow Pro API class
 */

public class PFProAPI extends java.lang.Object
{
    private int Context;
    
    /**
     * PNVersion() - Returns the Payflow Pro Client Version string.
     */
	public native String Version();

    /**
     * ProcessTransaction() -
     *
     * This function processes a transaction with Verisign and returns
     * an integer response as defined in the Verisign Client documentation 
     * and also sets TransactionResp to the Name/Value reponse string.
     *
     * @param HostAddress Connect to address (Example: test.signio.com)
     * @param HostPort    Port to connect to (Example: 443)
     * @param ProxyAddres The address of your proxy server if you have one, "" otherwise
     * @param ProxyPort   The port of your proxy server if you have one, "" otherwise
     * @param ProxyLogon  Your logon name on your proxy server if you have one, "" otherwise
     * @param ProxyPassword Your password on your proxy server if you have one, "" otherwise
     * @param ParmList Variables passed to Verisign.  See Verisign Integration Documentation.
     * @param Timeout Seconds in before transaction fails due to timeout
     */

	/**
	 * CreateContext() -
	 *
	 * This function creates a context which is used to communicate with
	 * the Verisign Payment Server.
	 *
     * @param HostAddress	Connect to address (Example: test.signio.com)
     * @param HostPort		Port to connect to (Example: 443)
     * @param Timeout		Seconds in before transaction fails due to timeout
     * @param ProxyAddress	The address of your proxy server if you have one, "" otherwise
     * @param ProxyPort		The port of your proxy server if you have one, 0 otherwise
     * @param ProxyLogon	Your logon name on your proxy server if you have one, "" otherwise
     * @param ProxyPassword Your password on your proxy server if you have one, "" otherwise
     */
    public native int CreateContext(String HostAddress,
                                    int HostPort,
                                    int Timeout,
                                    String ProxyAddress,
                                    int ProxyPort,
                                    String ProxyLogon,
                                    String ProxyPassword);

	/**
	 * DestroyContext() -
	 *
	 * Destroys the context created by CreateContext().
	 */
    public native int DestroyContext();

	/**
	 * SubmitTransaction() -
	 *
	 * Submits a transaction to the Verisign Payment Server.
	 *
	 * @param Context	Context created by CreateContext().
     * @param ParmList	Variables passed to Verisign.  See Verisign Integration Documentation.
	 */                                    
    public native String SubmitTransaction(String ParmList);

    private static native void Init();
    private static native void Cleanup();

    // Load the Verisign Payflow Pro API dll or shared object
    static {
        System.loadLibrary("pfprojni");
        Init();
    }
}


