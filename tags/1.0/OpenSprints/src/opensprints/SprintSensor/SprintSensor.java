/*
 * SprintSensor.java
 *
 * Monitors a serial port for two sensors.
 * Sensor one is wired to the DTR and DSR pins, and sensor two is wired to
 * RTS and CTS.
 *
 * @author Lyle Hanson
 */

package opensprints.SprintSensor;

/* imports */
import javax.comm.*;
import java.util.Enumeration;
import java.util.TooManyListenersException;

/**
 * SprintSensor
 *
 * Provides access to a sensor used by the OpenSprints system
 */
public class SprintSensor implements SerialPortEventListener
{
  /* constants */
  /* if this is given as the serial port name, test output will be generated */
  public static final String TEST_OUTPUT_PORTNAME = "Generate Test Output";
  private static final String APP_NAME = "OpenSprints Serial Port Monitor";
  /* serial port being monitored */
  private SerialPort serialPort = null;
  /* start time */
  private long startTime = 0;
  /* thread used to poll the sensor */
  private PollingThread pollingThread = null;
  /* if we're generating our own test data */
  private boolean GenerateTestData = false;
  /* serial pin states */
  private boolean oldDSRState = false;
  private boolean oldCTSState = false;
  private boolean currentDSRState = false;
  private boolean currentCTSState = false;
  
  /**
   * Creates a new instance of SprintSensor
   *
   * @param SerialPortName the name of the serial port to bind to   
   */
  public SprintSensor (String SerialPortName)
  {
    try
    {
      /* if we'll be generating test data */
      if ( (SerialPortName != null) && SerialPortName.equals (TEST_OUTPUT_PORTNAME))
      {
        GenerateTestData = true;
        System.out.println("debug: generating random test data");
      }
      /* otherwise we're opening a serial port */
      else
      {
        /* get the port identifier */
        CommPortIdentifier portId = CommPortIdentifier.getPortIdentifier (SerialPortName);
        /* open the selected port */
        serialPort = (SerialPort)portId.open (APP_NAME, 2000);
        System.out.println("debug: opened serial port " + SerialPortName);
        /* set the DTR and RTS bits so we can monitor the circuits */
        serialPort.setDTR (true);
        serialPort.setRTS (true);
        /* get notifications for the Data Set Ready and Clear To Send pins */
        serialPort.notifyOnDSR (true);
        serialPort.notifyOnCTS (true);
        /* register to receive events */
        serialPort.addEventListener (this);
      } /* else opening a serial port */
      System.out.println("debug: timer-resolution " + getTimerResolution () + " ms");
      /* start the timer */
      startTime = System.currentTimeMillis ();
      if (GenerateTestData)
      {
        /* start the polling thread (used for testing) */
        pollingThread = new PollingThread ();
        pollingThread.start ();
      }
    } /* try */
    catch (NoSuchPortException e)
    {
      System.out.println("exception: " + e);
    } /* NoSuchPortException */
    catch (PortInUseException e)
    {
      System.out.println("exception: " + e);
    } /* PortInUseException */
    catch (TooManyListenersException e)
    {
      System.out.println("exception:" + e);
    } /* TooManyListenersException e */
  } /* SprintSensor */

  /**
   * Called when receiving serial port events
   */
  public void serialEvent (SerialPortEvent e)
  {
    /* update the state of the pin represented by this event */
    if (e.getEventType () == SerialPortEvent.DSR)
      currentDSRState = e.getNewValue ();
    else if (e.getEventType () == SerialPortEvent.CTS)
      currentCTSState = e.getNewValue ();

    /* if either line changed and is currently set */
    if ( ((currentDSRState != oldDSRState) && currentDSRState) ||
         ((currentCTSState != oldCTSState) && currentCTSState) )
    {
      /* get the timestamp */
      float timeSinceStart = (float)(System.currentTimeMillis () - startTime) / (float)1000.0;
      /* print updates as necessary */
      if (currentDSRState)
        System.out.println("rider-one-tick: " + timeSinceStart + " seconds");
      if (currentCTSState)
        System.out.println("rider-two-tick: " + timeSinceStart + " seconds");
    } /* if either sensor flag changed */

    /* remember the states for the next iteration */
    oldDSRState = currentDSRState;
    oldCTSState = currentCTSState;
  } /* serialEvent */

  /**
   * Closes the serial port and stops the polling thread
   */
  public void close ()
  {
    /* if a polling thread was created */
    if (pollingThread != null)
    {
      /* stop the polling thread */
      pollingThread.requestStop ();
      /* now wait to ensure that it has stopped */
      try
      {
        /* wait up to five seconds for the thread to die */
        pollingThread.join (5000);
        if (pollingThread.isAlive ())
          /* timeout occurred thread has not finished */
          System.out.println("error: closing SprintSensor but polling thread won't die");
      } /* try */
      catch (InterruptedException e)
      {
        System.out.println("exception: " + e);
      } /* catch */
    } /* if a polling thread was created */
    /* if we're already monitoring a port, close it */
    if (serialPort != null)
      serialPort.close ();
  } /* close */

  /**
   * Releases any resources used by the object
   */
  protected void finalize() throws Throwable
  {
    try
    {
      /* close the serial port if in use */
      close();
    }
    finally
    {
      /* make sure inherited resources get released */
      super.finalize();
    }
  } /* finalize */

  /**
   * Calculates the resolution of System.currentTimeMillis () on
   * this system in milliseconds.
   */
  private int getTimerResolution ()
  {
    /* number of times to sample resolution */
    final int TIMER_ITERATIONS = 10;
    /* sample resolutions */
    long[] timerDeltas = new long[TIMER_ITERATIONS];
    float totalDeltas = 0;

    /* JIT/hotspot warmup */
    for (int r = 0; r < 3000; ++ r)
      System.currentTimeMillis ();
    long time = System.currentTimeMillis (), time_prev = time;
    for (int i = 0; i < TIMER_ITERATIONS; i++)
    {
      /* busy wait until system time changes */
      while (time == time_prev)
        time = System.currentTimeMillis ();
      /* save the difference */
      timerDeltas[i] = time - time_prev;
      time_prev = time;
    } /* for */
    /* calculate the total of the time deltas */
    for (int i=0; i<timerDeltas.length; i++)
      totalDeltas += (float)timerDeltas[i];
    /* return the average */
    return (int)(totalDeltas / TIMER_ITERATIONS);
  } /* getTimerResolution */

  /**
   * Monitors the sensor states
   */
  private class PollingThread extends Thread
  {
    /* flag to stop execution of the thread */
    private volatile boolean stopThread = false;

    public void run ()
    {
      boolean oldDSRState = false;
      boolean oldCTSState = false;
      boolean currentDSRState = false;
      boolean currentCTSState = false;
      
      while (!stopThread)
      {
        /* if we're generating our own test data */
        if (GenerateTestData)
        {
          /* generate a time between 100 and 200 ms */
          int randomInt = 100 + (int)(Math.random() * 200);
          /* reset the states */
          oldDSRState = false;
          oldCTSState = false;
          currentDSRState = false;
          currentCTSState = false;
          /* if the sleep time was even, set the DSR (sensor 1) flag */
          if ((randomInt % 2) == 0)
            currentDSRState = true;
          /* otherwise set the CTS (sensor 2) flag */
          else
            currentCTSState = true;
          /* sleep for the specified interval */
          try
          {
            Thread.sleep(randomInt);
          }
          catch (InterruptedException e)
          {
            System.out.println("exception: " + e);
          }
        } /* if generating test data */
        /* otherwise poll the serial port state */
        else
        {          
          currentDSRState = serialPort.isDSR ();
          currentCTSState = serialPort.isCTS ();
        } /* else polling serial port */

        /* if either line changed and is currently set */
        if ( ((currentDSRState != oldDSRState) && currentDSRState) ||
             ((currentCTSState != oldCTSState) && currentCTSState) )
        {
          /* get the timestamp */
          float timeSinceStart = (float)(System.currentTimeMillis () - startTime) / (float)1000.0;
          /* print updates as necessary */
          if (currentDSRState)
            System.out.println("rider-one-tick: " + timeSinceStart + " seconds");
          if (currentCTSState)
            System.out.println("rider-two-tick: " + timeSinceStart + " seconds");
        } /* if either sensor flag changed */

        /* remember the states for the next iteration */
        oldDSRState = currentDSRState;
        oldCTSState = currentCTSState;
      } /* while stop flag isn't set  */
    } /* run */
    
    /**
     * Tells the thread to end execution
     */
    public void requestStop ()
    {
      /* set the flag to end this thread */
      stopThread = true;
    }
  } /* PollingThread */

} /* SprintSensor */