/*
 * MonitorPanel.java
 *
 * Serves as the user interface to control sensors.
 *
 * @author Lyle Hanson
 */

package opensprints.SprintSensor;

/* imports */
import javax.comm.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Enumeration;
import javax.swing.*;
import javax.swing.border.TitledBorder;

/**
 * MonitorPanel
 */
public class MonitorPanel extends JPanel
{
  /* default component size */
  private final static Dimension DEFAULT_COMPONENT_DIMENSION = new Dimension (175, 25);
  /* combo box listing serial ports */
  private JComboBox serialPortComboBox = null;
  /* the sensor we're currently monitoring */
  SprintSensor sprintSensor = null;
  /* serial port currently being monitored */
  SerialPort serialPort = null;

  /** Creates a new instance of MonitorPanel */
  public MonitorPanel ()
  {    
    /* panel containing the port selection components */
    JPanel selectPortsPanel = new JPanel ();
    /* button to begin monitoring the current serial port */
    JButton activateButton = new JButton ("Activate");
    /* list of all comm ports */
    Enumeration commPorts = CommPortIdentifier.getPortIdentifiers ();

    /* set the border on the ports panel */
    selectPortsPanel.setBorder (new TitledBorder ("Select Sensor Port"));
    selectPortsPanel.setLayout (new BoxLayout (selectPortsPanel, BoxLayout.Y_AXIS));
    /* create the combo box */
    serialPortComboBox = new JComboBox ();
    /* size the combo box */
    serialPortComboBox.setPreferredSize (DEFAULT_COMPONENT_DIMENSION);
    /* while we have comm ports */
    while (commPorts.hasMoreElements ())
    {
      CommPortIdentifier port = (CommPortIdentifier)commPorts.nextElement ();
      /* if this is a serial port */
      if (port.getPortType () == CommPortIdentifier.PORT_SERIAL)
      {
        boolean isDuplicatePort = false;
        for (int i=0; i<serialPortComboBox.getItemCount (); i++)
          if (port.getName ().equals (serialPortComboBox.getItemAt (i)))
          {
            /* set the flag and exit the loop */
            isDuplicatePort = true;
            break;
          }
        /* add the serial port if it isn't in the list already */
        if (!isDuplicatePort)
          serialPortComboBox.addItem (port.getName ());
      }
    } /* while we have comm ports */
    /* add an option to generate test data */
    serialPortComboBox.addItem (SprintSensor.TEST_OUTPUT_PORTNAME);
    /* add an action for the button */
    activateButton.addActionListener (new ActivateAction ());
    /* add the combo box to the serial ports panel */
    selectPortsPanel.add (serialPortComboBox);
    selectPortsPanel.add (Box.createRigidArea (new Dimension (0, 10)));
    activateButton.setAlignmentX (Component.CENTER_ALIGNMENT);
    selectPortsPanel.add (activateButton);
    add (selectPortsPanel/*, constraints*/);
  } /* MonitorPanel */

  /**
   * Begins monitoring the currently selected sensor
   */
  private class ActivateAction extends AbstractAction
  {
    /**
      * actionPerformed
      */
    public void actionPerformed (ActionEvent e)
    {
      /* if there is an existing sensor running, shut it down first */
      if (sprintSensor != null)
        sprintSensor.close ();
      /* create the sensor object bound to the selected port */      
      sprintSensor = new SprintSensor ((String)serialPortComboBox.getSelectedItem ());
    } /* actionPerformed */
  } /* ActivateAction */

} /* MonitorPanel */