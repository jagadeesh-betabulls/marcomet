/**********************************************************************
Description:	This is the heart of Connection Pooling.  It defines all
				of the chekout and checkin methods and contains the
				hashtables maintaining the connections.

History:
	Date		Author			Description
	----		------			-----------
	6/8/2001	Brian Murphy	Created
	10/11/01	td				made function final

**********************************************************************/

package com.marcomet.jdbc;

import java.sql.*;
import java.util.*;

public abstract class ObjectPool {
	
	private long expirationTime;
	private long idleExpirationTime;
	private static Hashtable locked;
	private static Hashtable unlocked;
	private CleanupThread cleaner;
	private int numberAlwaysAvailable;

	public ObjectPool() {
		expirationTime = 60000; // 60 seconds
		idleExpirationTime = 60000; // 60 seconds
		numberAlwaysAvailable = 5;
		
		locked = new Hashtable();
		unlocked = new Hashtable();

		cleaner = new CleanupThread(this, expirationTime);
		cleaner.start();
	}
	// Make this void is we move away from Solaris
	synchronized int checkIn(Object o) {

		Object temp = locked.remove(o);
		if (unlocked.size() > numberAlwaysAvailable) {
			o = null;
		} else {
			unlocked.put(o, new Long(System.currentTimeMillis()));
		}
		
		return 1;
	}
	synchronized Object checkOut() throws SQLException {

		long now = System.currentTimeMillis();
		Object o;

		if (unlocked.size() > 0) {

			Enumeration e = unlocked.keys();
			while(e.hasMoreElements()) {

				o = e.nextElement();
				if((now - ((Long)unlocked.get(o)).longValue() ) > expirationTime) {
					// object has expired
					unlocked.remove(o);
					int i = expire(o);
					o = null;
				} else {

					if(validate(o)) {
						unlocked.remove(o);
						locked.put(o, new Long(now));
						return(o);
					} else {
						// object failed validation
						unlocked.remove(o);
						int i = expire(o);
						o = null;
					}
				}
			}
		}
		// no objects available, create a new one
		o = create();
		locked.put(o, new Long(now));
		return(o);
	}
	public final synchronized void cleanUp() {
		Object lockedObject, unlockedObject;
		long now = System.currentTimeMillis();
	
		if (idleExpirationTime > 0) {
			Enumeration unlockedObjects = unlocked.keys();

			while (unlocked.size() > numberAlwaysAvailable && unlockedObjects.hasMoreElements()) {
				unlockedObject = unlockedObjects.nextElement();
				Long leaseStartTime = (Long) unlocked.get(unlockedObject);

				if ((now - leaseStartTime.longValue()) > idleExpirationTime) {
					unlocked.remove(unlockedObject);
					int i = expire(unlockedObject);
					unlockedObject = null;
				}
			}
		}

		try {
			// Change this back to unlocked.size()
			if (getPoolSize()  < numberAlwaysAvailable)
				initializeConnections();
		} catch (SQLException ex) {
		}
	}
	abstract Object create() throws SQLException;
	// Make this void is we move away from Solaris
	abstract int expire(Object o);
	public final synchronized int getAvailablePoolSize() {
		return unlocked.size();
	}
	public final synchronized int getPoolSize() {
		return unlocked.size() + locked.size();
	}
	public final synchronized int getUsedPoolSize() {
		return locked.size();
	}
	// Make this void is we move away from Solaris
	public final synchronized int initializeConnections() throws SQLException {
		for (int i=1; unlocked.size() < numberAlwaysAvailable; i++) {
			Object o;
			o = create();
			unlocked.put(o, new Long(System.currentTimeMillis()));
		}
		return 1;
	}
	abstract boolean validate(Object o);
}
