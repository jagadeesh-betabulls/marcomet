/**********************************************************************
Description:	This thread cleans up the connection pool hashtables

History:
	Date		Author			Description
	----		------			-----------
	6/8/2001	Brian Murphy	Created
	10/11/01	td				made functions final

**********************************************************************/

package com.marcomet.jdbc;

public class CleanupThread extends Thread {

	private ObjectPool pool;
	private long sleepTime;

	public CleanupThread(ObjectPool pool, long sleepTime) {
		this.pool = pool;
		this.sleepTime = sleepTime; 
	}
	public final void run() {
		while(true) {
			try {
				sleep(sleepTime);
				pool.cleanUp();
			} catch (InterruptedException ex) {
				// ignore it
			} catch (Exception ex) {
				try {
					//com.marcomet.tools.MessageLogger.logMessage("There was an exception during cleanup: " + ex.getMessage());
				} catch (Exception e) {
				}
			}
		} // while
   }   
}
