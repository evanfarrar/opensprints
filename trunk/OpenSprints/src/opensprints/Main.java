/*
 * Main.java
 *
 * Main class of the opensprints package.
 *
 * @author Lyle Hanson
 */

package opensprints;

/* imports */
import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.swing.*;
import opensprints.SprintSensor.*;

/**
 * Main
 */
public class Main
{
  /* constants */
  private static final String APP_NAME = "OpenSprints";
//  private static final int APP_WIDTH = 200;  
//  private static final int APP_HEIGHT = 200;

  /** Creates a new instance of Main */
  public Main ()
  {
    /* schedule the GUI to be created on the event dispatch thread */
    SwingUtilities.invokeLater(new Runnable()
    {
      public void run()
      {
        createAndShowGUI();
      } /* run */
    }); /* invokeLater */
  } /* Main */
  
  /**
   * @param args the command line arguments
   */
  public static void main (String[] args)
  {
    /* instantiate the Main object */
    new Main ();
  } /* main */

  /**
   * Creates the GUI components and makes them visible
   */
  private void createAndShowGUI ()
  {
    /* create the frame for the application */
    final JFrame mainFrame = new JFrame (APP_NAME);
    /* set the frame to exit the app on close */
    mainFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    /* set the preferred size */
    //mainFrame.setPreferredSize (new Dimension (APP_WIDTH, APP_HEIGHT));
    mainFrame.setResizable (false);
    /* add the monitor panel to the frame */
    mainFrame.getContentPane ().add (new MonitorPanel (), BorderLayout.CENTER);
    /* pack the frame */
    mainFrame.pack ();
    /* show the frame */
    mainFrame.setVisible (true);
  } /* createAndShowGUI */

} /* Main */